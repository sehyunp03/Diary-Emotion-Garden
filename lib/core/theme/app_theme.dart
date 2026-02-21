import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // 기본 시드 색상 (평온한 초록 정원)
  static const Color defaultSeedColor = Color(0xFF7CB686);

  // 감정별 테마 색상 매핑
  static const Map<String, Color> emotionColors = {
    'joy': Color(0xFFFFD93D),       // 밝은 노랑
    'sadness': Color(0xFF6B9FD4),   // 차분한 파랑
    'anger': Color(0xFFFF6B6B),     // 붉은 오렌지
    'calm': Color(0xFF7CB686),      // 평온한 초록
    'anxiety': Color(0xFFB39DDB),   // 보라
    'surprise': Color(0xFFFFB347),  // 주황
    'boredom': Color(0xFFB0BEC5),   // 회색
    'trust': Color(0xFF81C784),     // 신뢰의 초록
  };

  // 감정별 배경 그라디언트 색상
  static const Map<String, List<Color>> emotionGradients = {
    'joy': [Color(0xFFFFF9C4), Color(0xFFFFECB3)],
    'sadness': [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    'anger': [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
    'calm': [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    'anxiety': [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
    'surprise': [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    'boredom': [Color(0xFFECEFF1), Color(0xFFCFD8DC)],
    'trust': [Color(0xFFE8F5E9), Color(0xFFA5D6A7)],
  };

  static ThemeData getTheme(Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.notoSansKrTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSansKr(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        displayMedium: GoogleFonts.notoSansKr(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        headlineLarge: GoogleFonts.notoSansKr(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        headlineMedium: GoogleFonts.notoSansKr(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleLarge: GoogleFonts.notoSansKr(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleMedium: GoogleFonts.notoSansKr(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.notoSansKr(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        bodyMedium: GoogleFonts.notoSansKr(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.notoSansKr(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// 지배적인 감정에 따라 씨드 색상 반환
  static Color getSeedColorForEmotion(String dominantEmotion) {
    return emotionColors[dominantEmotion] ?? defaultSeedColor;
  }

  /// 감정 점수 맵에서 지배적인 감정 추출
  static String getDominantEmotion(Map<String, int> emotionScores) {
    if (emotionScores.isEmpty) return 'calm';
    return emotionScores.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  /// 감정별 배경 그라디언트
  static List<Color> getGradientForEmotion(String emotion) {
    return emotionGradients[emotion] ?? emotionGradients['calm']!;
  }
}
