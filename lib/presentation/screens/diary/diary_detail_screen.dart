import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/diary_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/emotion_bar.dart';

class DiaryDetailScreen extends StatelessWidget {
  final DiaryModel diary;
  final bool isNewDiary;

  const DiaryDetailScreen({
    super.key,
    required this.diary,
    this.isNewDiary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dominantEmotion = diary.emotions.dominantEmotion;
    final emotionColor =
        AppTheme.emotionColors[dominantEmotion] ?? AppTheme.defaultSeedColor;
    final gradientColors = AppTheme.getGradientForEmotion(dominantEmotion);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // 정원 이미지 앱바
          SliverAppBar(
            expandedHeight: size.height * 0.45,
            pinned: true,
            backgroundColor: emotionColor.withOpacity(0.3),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => _confirmDelete(context),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 정원 이미지
                  if (diary.gardenImageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: diary.gardenImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: emotionColor.withOpacity(0.2),
                        highlightColor: emotionColor.withOpacity(0.4),
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.local_florist,
                              size: 80,
                              color: emotionColor.withOpacity(0.4)),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '🌿',
                          style: const TextStyle(fontSize: 80),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1.1, 1.1),
                              duration: 2000.ms,
                            ),
                      ),
                    ),

                  // 하단 그라디언트
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            theme.colorScheme.surface,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 새 일기 축하 배너
                  if (isNewDiary)
                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: emotionColor.withOpacity(0.3),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Text(
                            '✨ 오늘의 정원이 피어났어요!',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: emotionColor,
                              fontSize: 15,
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 500.ms)
                            .scale(
                              begin: const Offset(0.5, 0.5),
                              curve: Curves.elasticOut,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 상세 내용
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 & 날씨 & 기분 헤더
                  _DiaryHeader(
                    diary: diary,
                    emotionColor: emotionColor,
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  // 감정 분석 섹션
                  _EmotionSection(
                    emotions: diary.emotions,
                    emotionColor: emotionColor,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 20),

                  // AI 요약 섹션
                  if (diary.summary.isNotEmpty)
                    _SummarySection(
                      summary: diary.summary,
                      emotionColor: emotionColor,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                  if (diary.summary.isNotEmpty) const SizedBox(height: 20),

                  // 일기 원문 섹션
                  _DiaryContentSection(
                    content: diary.content,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 20),

                  // 프롬프트 (접기 가능)
                  if (diary.imagePrompt.isNotEmpty)
                    _PromptSection(
                      prompt: diary.imagePrompt,
                    ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('일기 삭제'),
        content: const Text('이 일기와 정원 이미지를 삭제할까요?\n삭제 후에는 복구할 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              final diaryProvider = context.read<DiaryProvider>();
              final userId = authProvider.firebaseUser?.uid;
              if (userId != null) {
                await diaryProvider.deleteDiary(userId, diary);
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

class _DiaryHeader extends StatelessWidget {
  final DiaryModel diary;
  final Color emotionColor;

  const _DiaryHeader({required this.diary, required this.emotionColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = diary.createdAt;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${date.year}년 ${date.month}월 ${date.day}일',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (diary.weather.isNotEmpty)
                Text(
                  diary.weather,
                  style: const TextStyle(fontSize: 20),
                ),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: emotionColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: emotionColor.withOpacity(0.4),
            ),
          ),
          child: Text(
            diary.mood,
            style: theme.textTheme.titleMedium?.copyWith(
              color: emotionColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmotionSection extends StatelessWidget {
  final EmotionScore emotions;
  final Color emotionColor;

  const _EmotionSection(
      {required this.emotions, required this.emotionColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: emotionColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: emotionColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🎭',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 감정 분석',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: emotionColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          EmotionBar(emotions: emotions),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final String summary;
  final Color emotionColor;

  const _SummarySection(
      {required this.summary, required this.emotionColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('✨', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'AI 일기 요약',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.7,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaryContentSection extends StatelessWidget {
  final String content;

  const _DiaryContentSection({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('📝', style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              '나의 일기',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.8,
            ),
          ),
        ),
      ],
    );
  }
}

class _PromptSection extends StatefulWidget {
  final String prompt;

  const _PromptSection({required this.prompt});

  @override
  State<_PromptSection> createState() => _PromptSectionState();
}

class _PromptSectionState extends State<_PromptSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('🎨', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  '정원 이미지 프롬프트',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Text(
                widget.prompt,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  height: 1.6,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
