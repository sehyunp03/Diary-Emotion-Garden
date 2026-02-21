import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../diary/diary_detail_screen.dart';

class WriteDiaryScreen extends StatefulWidget {
  const WriteDiaryScreen({super.key});

  @override
  State<WriteDiaryScreen> createState() => _WriteDiaryScreenState();
}

class _WriteDiaryScreenState extends State<WriteDiaryScreen> {
  final _contentController = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedWeather = '';
  final _weatherOptions = ['☀️', '⛅', '🌧️', '🌩️', '❄️', '🌫️'];

  @override
  void dispose() {
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<AuthProvider, DiaryProvider>(
      builder: (context, authProvider, diaryProvider, _) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: theme.colorScheme.surface,
              appBar: AppBar(
                title: const Text('오늘의 정원 일기'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilledButton(
                      onPressed: _contentController.text.trim().length < 10
                          ? null
                          : () => _submitDiary(
                                context,
                                authProvider,
                                diaryProvider,
                              ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('정원 피우기 🌸'),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 날씨 선택
                    _WeatherSelector(
                      selected: _selectedWeather,
                      options: _weatherOptions,
                      onSelected: (w) => setState(() => _selectedWeather = w),
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // AI 안내 배너
                    _AiInfoBanner(
                      themeColor: diaryProvider.themeColor,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                    const SizedBox(height: 20),

                    // 일기 작성 영역
                    _DiaryTextField(
                      controller: _contentController,
                      onChanged: (_) => setState(() {}),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 16),

                    // 글자수 & 안내
                    Row(
                      children: [
                        Text(
                          '최소 10자 이상 써야 정원이 피어나요 🌱',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_contentController.text.length}자',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: _contentController.text.trim().length < 10
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // 로딩 오버레이
            if (diaryProvider.isCreating)
              const LoadingOverlay(
                message: 'AI가 정원을 가꾸는 중...',
                subMessage: '감정을 분석하고 당신만의 정원 이미지를 만들고 있어요.\n잠시만 기다려주세요 🌿',
              ),
          ],
        );
      },
    );
  }

  Future<void> _submitDiary(
    BuildContext context,
    AuthProvider authProvider,
    DiaryProvider diaryProvider,
  ) async {
    final content = _contentController.text.trim();
    if (content.length < 10) return;

    final userId = authProvider.firebaseUser?.uid;
    if (userId == null) return;

    // 키보드 닫기
    FocusScope.of(context).unfocus();

    final diary = await diaryProvider.createDiary(
      userId: userId,
      content: content,
      weather: _selectedWeather,
    );

    if (!mounted) return;

    if (diary != null) {
      // 성공 - 상세 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DiaryDetailScreen(
            diary: diary,
            isNewDiary: true,
          ),
        ),
      );
    } else if (diaryProvider.createErrorMessage != null) {
      // 에러 스낵바
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(diaryProvider.createErrorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      diaryProvider.resetCreateStatus();
    }
  }
}

class _WeatherSelector extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _WeatherSelector({
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 날씨는?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: options.map((weather) {
            final isSelected = selected == weather;
            return GestureDetector(
              onTap: () => onSelected(isSelected ? '' : weather),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    weather,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AiInfoBanner extends StatelessWidget {
  final Color themeColor;

  const _AiInfoBanner({required this.themeColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            '✨',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI가 감정을 분석해요',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: themeColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '8가지 감정(기쁨, 슬픔, 분노, 평온, 불안, 놀람, 지루함, 신뢰)을 분석해 나만의 정원 이미지를 만들어드려요.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    height: 1.5,
                    color: themeColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaryTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _DiaryTextField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: 18,
        minLines: 12,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.8,
        ),
        decoration: InputDecoration(
          hintText:
              '오늘 하루는 어떠셨나요?\n\n기쁜 일, 슬픈 일, 놀라운 일...\n무엇이든 솔직하게 적어보세요.\nAI가 감정을 읽고 당신만의 정원을 피워드릴게요 🌸',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            height: 1.8,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
