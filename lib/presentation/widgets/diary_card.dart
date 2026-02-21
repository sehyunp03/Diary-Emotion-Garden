import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/diary_model.dart';
import '../../core/theme/app_theme.dart';

class DiaryCard extends StatelessWidget {
  final DiaryModel diary;
  final VoidCallback? onTap;
  final int index;

  const DiaryCard({
    super.key,
    required this.diary,
    this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dominantEmotion = diary.emotions.dominantEmotion;
    final emotionColor = AppTheme.emotionColors[dominantEmotion] ??
        AppTheme.defaultSeedColor;
    final gradientColors =
        AppTheme.getGradientForEmotion(dominantEmotion);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: emotionColor.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: [
              // 정원 이미지 썸네일
              _GardenThumbnail(
                imageUrl: diary.gardenImageUrl,
                emotionColor: emotionColor,
              ),
              // 일기 내용
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜 + 기분
                      Row(
                        children: [
                          Text(
                            diary.formattedDate,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: emotionColor.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: emotionColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              diary.mood,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                                color: emotionColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 일기 요약
                      Text(
                        diary.summary.isNotEmpty ? diary.summary : diary.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          height: 1.5,
                          color: theme.colorScheme.onSurface.withOpacity(0.75),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // 상위 감정 칩
                      _EmotionChips(emotions: diary.emotions),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}

class _GardenThumbnail extends StatelessWidget {
  final String imageUrl;
  final Color emotionColor;

  const _GardenThumbnail({
    required this.imageUrl,
    required this.emotionColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 100,
        height: 110,
        decoration: BoxDecoration(
          color: emotionColor.withOpacity(0.15),
        ),
        child: Icon(
          Icons.local_florist,
          color: emotionColor.withOpacity(0.5),
          size: 36,
        ),
      );
    }

    return SizedBox(
      width: 100,
      height: 110,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: emotionColor.withOpacity(0.1),
          highlightColor: emotionColor.withOpacity(0.3),
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, url, error) => Container(
          color: emotionColor.withOpacity(0.15),
          child: Icon(
            Icons.broken_image_outlined,
            color: emotionColor.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

class _EmotionChips extends StatelessWidget {
  final EmotionScore emotions;

  const _EmotionChips({required this.emotions});

  @override
  Widget build(BuildContext context) {
    final scores = emotions.toMap();
    final topEmotions = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final emotionLabels = {
      'joy': '기쁨',
      'sadness': '슬픔',
      'anger': '분노',
      'calm': '평온',
      'anxiety': '불안',
      'surprise': '놀람',
      'boredom': '지루함',
      'trust': '신뢰',
    };

    final top3 = topEmotions.take(3).where((e) => e.value > 0).toList();

    return Wrap(
      spacing: 4,
      children: top3.map((entry) {
        final color =
            AppTheme.emotionColors[entry.key] ?? AppTheme.defaultSeedColor;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '${emotionLabels[entry.key]} ${entry.value}',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}
