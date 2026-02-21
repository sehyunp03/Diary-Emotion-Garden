import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/garden_hero.dart';
import '../../widgets/diary_card.dart';
import '../diary/write_diary_screen.dart';
import '../diary/diary_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _listenerStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenerStarted) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.firebaseUser != null) {
        context
            .read<DiaryProvider>()
            .startListening(authProvider.firebaseUser!.uid);
        _listenerStarted = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<AuthProvider, DiaryProvider>(
      builder: (context, authProvider, diaryProvider, _) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              // 커스텀 앱바
              SliverAppBar(
                expandedHeight: 0,
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: _HomeAppBar(
                  displayName:
                      authProvider.userModel?.displayName ?? '정원사',
                  photoUrl: authProvider.userModel?.photoUrl,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => _showSettingsBottomSheet(
                        context, authProvider),
                  ),
                ],
              ),

              // 오늘 날짜
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    _getTodayText(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ),
              ),

              // 오늘의 정원 히어로 섹션
              SliverToBoxAdapter(
                child: GardenHero(
                  diary: diaryProvider.todayDiary,
                  themeColor: diaryProvider.themeColor,
                  onTap: diaryProvider.todayDiary != null
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DiaryDetailScreen(
                                diary: diaryProvider.todayDiary!,
                              ),
                            ),
                          )
                      : null,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 일기 목록 헤더
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        '🌸 나의 정원 기록',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (diaryProvider.diaries.isNotEmpty)
                        Text(
                          '${diaryProvider.diaries.length}개',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 일기 목록
              if (diaryProvider.status == DiaryStatus.loading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (diaryProvider.diaries.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyDiaryList(
                    themeColor: diaryProvider.themeColor,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final diary = diaryProvider.diaries[index];
                      return DiaryCard(
                        diary: diary,
                        index: index,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DiaryDetailScreen(diary: diary),
                          ),
                        ),
                      );
                    },
                    childCount: diaryProvider.diaries.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // 일기 작성 FAB
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WriteDiaryScreen(),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('오늘 일기 쓰기'),
            elevation: 4,
          ).animate().slideY(begin: 2, end: 0, delay: 500.ms, duration: 600.ms,
              curve: Curves.elasticOut),
        );
      },
    );
  }

  String _getTodayText() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR');
    try {
      return formatter.format(now);
    } catch (_) {
      return '${now.year}년 ${now.month}월 ${now.day}일';
    }
  }

  void _showSettingsBottomSheet(
      BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 24),
            // 사용자 정보
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      authProvider.userModel?.photoUrl != null
                          ? CachedNetworkImageProvider(
                              authProvider.userModel!.photoUrl!)
                          : null,
                  child: authProvider.userModel?.photoUrl == null
                      ? const Text('🌿', style: TextStyle(fontSize: 24))
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.userModel?.displayName ?? '정원사',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      authProvider.userModel?.email ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('로그아웃'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onTap: () {
                Navigator.pop(context);
                authProvider.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  final String displayName;
  final String? photoUrl;

  const _HomeAppBar({required this.displayName, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: photoUrl != null
              ? CachedNetworkImageProvider(photoUrl!)
              : null,
          backgroundColor: theme.colorScheme.primaryContainer,
          child:
              photoUrl == null ? const Text('🌿', style: TextStyle(fontSize: 16)) : null,
        ),
        const SizedBox(width: 10),
        Text(
          '$displayName의 정원',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyDiaryList extends StatelessWidget {
  final Color themeColor;

  const _EmptyDiaryList({required this.themeColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      child: Column(
        children: [
          Text(
            '🌱',
            style: const TextStyle(fontSize: 64),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 2000.ms,
              ),
          const SizedBox(height: 16),
          Text(
            '첫 번째 정원을 피워볼까요?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘의 감정을 일기로 쓰면\nAI가 나만의 정원을 만들어드려요',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}
