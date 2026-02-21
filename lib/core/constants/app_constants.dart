class AppConstants {
  AppConstants._();

  static const String appName = 'Garden Diary';
  static const String appVersion = '1.0.0';

  // Firestore 컬렉션 이름
  static const String usersCollection = 'users';
  static const String diariesCollection = 'diaries';

  // Storage 경로
  static const String gardenImagesPath = 'garden_images';

  // OpenAI 설정
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String gptModel = 'gpt-4o';
  static const String dalleModel = 'dall-e-3';
  static const String dalleImageSize = '1024x1024';
  static const String dalleImageQuality = 'standard';

  // 감정 목록 (한국어)
  static const List<String> emotions = [
    '기쁨',
    '슬픔',
    '분노',
    '평온',
    '불안',
    '놀람',
    '지루함',
    '신뢰',
  ];

  // 감정 영어 키 (API 통신용)
  static const List<String> emotionKeys = [
    'joy',
    'sadness',
    'anger',
    'calm',
    'anxiety',
    'surprise',
    'boredom',
    'trust',
  ];

  // 감정별 이모지
  static const Map<String, String> emotionEmojis = {
    'joy': '😊',
    'sadness': '😢',
    'anger': '😠',
    'calm': '😌',
    'anxiety': '😰',
    'surprise': '😲',
    'boredom': '😑',
    'trust': '🤝',
  };

  // 애니메이션 지속시간
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 600);
  static const Duration longAnimation = Duration(milliseconds: 1200);
}
