import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;
  final String subMessage;

  const LoadingOverlay({
    super.key,
    this.message = 'AI가 정원을 가꾸는 중...',
    this.subMessage = '감정을 분석하고 당신만의 정원을 만들고 있어요',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 애니메이션 아이콘
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.1, 1.1),
                        duration: 1200.ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.1, 1.1),
                        end: const Offset(0.8, 0.8),
                        duration: 1200.ms,
                        curve: Curves.easeInOut,
                      ),
                  Text(
                    '🌱',
                    style: const TextStyle(fontSize: 44),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .rotate(duration: 3000.ms, begin: -0.05, end: 0.05)
                      .then()
                      .rotate(duration: 3000.ms, begin: 0.05, end: -0.05),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                message,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                subMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // 진행 표시줄
              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(100),
                backgroundColor:
                    theme.colorScheme.primaryContainer.withOpacity(0.3),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
