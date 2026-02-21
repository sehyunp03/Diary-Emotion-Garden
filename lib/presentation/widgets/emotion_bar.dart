import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/diary_model.dart';
import '../../core/theme/app_theme.dart';

class EmotionBar extends StatelessWidget {
  final EmotionScore emotions;
  final bool showLabels;
  final double height;

  const EmotionBar({
    super.key,
    required this.emotions,
    this.showLabels = true,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final emotionData = [
      _EmotionData('기쁨', 'joy', emotions.joy, AppTheme.emotionColors['joy']!),
      _EmotionData('슬픔', 'sadness', emotions.sadness, AppTheme.emotionColors['sadness']!),
      _EmotionData('분노', 'anger', emotions.anger, AppTheme.emotionColors['anger']!),
      _EmotionData('평온', 'calm', emotions.calm, AppTheme.emotionColors['calm']!),
      _EmotionData('불안', 'anxiety', emotions.anxiety, AppTheme.emotionColors['anxiety']!),
      _EmotionData('놀람', 'surprise', emotions.surprise, AppTheme.emotionColors['surprise']!),
      _EmotionData('지루함', 'boredom', emotions.boredom, AppTheme.emotionColors['boredom']!),
      _EmotionData('신뢰', 'trust', emotions.trust, AppTheme.emotionColors['trust']!),
    ];

    return Column(
      children: emotionData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _EmotionBarItem(
            data: data,
            height: height,
            showLabel: showLabels,
            animationDelay: Duration(milliseconds: index * 80),
          ),
        );
      }).toList(),
    );
  }
}

class _EmotionBarItem extends StatelessWidget {
  final _EmotionData data;
  final double height;
  final bool showLabel;
  final Duration animationDelay;

  const _EmotionBarItem({
    required this.data,
    required this.height,
    required this.showLabel,
    required this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fillRatio = data.score / 5.0;

    return Row(
      children: [
        if (showLabel) ...[
          SizedBox(
            width: 44,
            child: Text(
              data.label,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Stack(
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: fillRatio,
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: data.color,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                )
                    .animate(delay: animationDelay)
                    .slideX(begin: -1, end: 0, curve: Curves.easeOutCubic)
                    .fadeIn(),
              ],
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            child: Text(
              '${data.score}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: data.color,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmotionData {
  final String label;
  final String key;
  final int score;
  final Color color;

  const _EmotionData(this.label, this.key, this.score, this.color);
}
