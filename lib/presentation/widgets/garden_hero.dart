import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/diary_model.dart';
import '../../core/theme/app_theme.dart';

class GardenHero extends StatelessWidget {
  final DiaryModel? diary;
  final VoidCallback? onTap;
  final Color themeColor;

  const GardenHero({
    super.key,
    this.diary,
    this.onTap,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    if (diary == null) {
      return _EmptyGarden(themeColor: themeColor, size: size);
    }

    final dominantEmotion = diary!.emotions.dominantEmotion;
    final gradientColors = AppTheme.getGradientForEmotion(dominantEmotion);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size.height * 0.42,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(36),
            bottomRight: Radius.circular(36),
          ),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 정원 이미지
            if (diary!.gardenImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                child: CachedNetworkImage(
                  imageUrl: diary!.gardenImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _GardenLoadingShimmer(
                    color: themeColor,
                  ),
                  errorWidget: (context, url, error) =>
                      _GardenPlaceholder(themeColor: themeColor),
                ),
              ),

            // 하단 그라디언트 오버레이
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 일기 정보 오버레이
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          '🌿 오늘의 정원',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          diary!.mood,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    diary!.summary.isNotEmpty
                        ? diary!.summary
                        : diary!.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),
    );
  }
}

class _EmptyGarden extends StatelessWidget {
  final Color themeColor;
  final Size size;

  const _EmptyGarden({required this.themeColor, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: size.height * 0.42,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        gradient: LinearGradient(
          colors: [
            themeColor.withOpacity(0.3),
            themeColor.withOpacity(0.15),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_outlined,
            size: 80,
            color: themeColor.withOpacity(0.5),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 2000.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 20),
          Text(
            '아직 오늘의 정원이 없어요',
            style: theme.textTheme.titleMedium?.copyWith(
              color: themeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '일기를 쓰면 나만의 정원이 피어나요 🌱',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: themeColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

class _GardenLoadingShimmer extends StatelessWidget {
  final Color color;

  const _GardenLoadingShimmer({required this.color});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: color.withOpacity(0.2),
      highlightColor: color.withOpacity(0.4),
      child: Container(
        color: Colors.white,
      ),
    );
  }
}

class _GardenPlaceholder extends StatelessWidget {
  final Color themeColor;

  const _GardenPlaceholder({required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.getGradientForEmotion('calm'),
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_florist,
          size: 80,
          color: themeColor.withOpacity(0.4),
        ),
      ),
    );
  }
}
