import 'package:cloud_firestore/cloud_firestore.dart';

class EmotionScore {
  final int joy;       // 기쁨
  final int sadness;   // 슬픔
  final int anger;     // 분노
  final int calm;      // 평온
  final int anxiety;   // 불안
  final int surprise;  // 놀람
  final int boredom;   // 지루함
  final int trust;     // 신뢰

  const EmotionScore({
    this.joy = 0,
    this.sadness = 0,
    this.anger = 0,
    this.calm = 0,
    this.anxiety = 0,
    this.surprise = 0,
    this.boredom = 0,
    this.trust = 0,
  });

  factory EmotionScore.fromMap(Map<String, dynamic> map) {
    return EmotionScore(
      joy: (map['joy'] ?? 0).toInt(),
      sadness: (map['sadness'] ?? 0).toInt(),
      anger: (map['anger'] ?? 0).toInt(),
      calm: (map['calm'] ?? 0).toInt(),
      anxiety: (map['anxiety'] ?? 0).toInt(),
      surprise: (map['surprise'] ?? 0).toInt(),
      boredom: (map['boredom'] ?? 0).toInt(),
      trust: (map['trust'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'joy': joy,
      'sadness': sadness,
      'anger': anger,
      'calm': calm,
      'anxiety': anxiety,
      'surprise': surprise,
      'boredom': boredom,
      'trust': trust,
    };
  }

  /// 지배적인 감정 반환 (가장 높은 점수)
  String get dominantEmotion {
    final scores = toMap();
    String dominant = 'calm';
    int maxScore = 0;
    scores.forEach((key, value) {
      if (value > maxScore) {
        maxScore = value;
        dominant = key;
      }
    });
    return dominant;
  }

  /// 모든 감정 점수의 합계
  int get totalScore {
    return joy + sadness + anger + calm + anxiety + surprise + boredom + trust;
  }

  /// 감정 점수를 비율로 반환 (0.0 ~ 1.0)
  Map<String, double> get ratios {
    final total = totalScore;
    if (total == 0) return {};
    final scores = toMap();
    return scores.map((key, value) => MapEntry(key, value / total));
  }
}

class DiaryModel {
  final String id;
  final String userId;
  final String content;
  final String summary;       // AI가 생성한 일기 요약
  final EmotionScore emotions;
  final String gardenImageUrl;
  final String imagePrompt;   // DALL-E에 보낸 프롬프트 (참고용)
  final DateTime createdAt;
  final DateTime updatedAt;
  final String weather;       // 날씨 (선택)
  final String mood;          // 전체적인 기분 요약 (한 단어)

  const DiaryModel({
    required this.id,
    required this.userId,
    required this.content,
    this.summary = '',
    required this.emotions,
    this.gardenImageUrl = '',
    this.imagePrompt = '',
    required this.createdAt,
    required this.updatedAt,
    this.weather = '',
    this.mood = '평온',
  });

  factory DiaryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiaryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      summary: data['summary'] ?? '',
      emotions: EmotionScore.fromMap(
        (data['emotions'] as Map<String, dynamic>?) ?? {},
      ),
      gardenImageUrl: data['gardenImageUrl'] ?? '',
      imagePrompt: data['imagePrompt'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      weather: data['weather'] ?? '',
      mood: data['mood'] ?? '평온',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'content': content,
      'summary': summary,
      'emotions': emotions.toMap(),
      'gardenImageUrl': gardenImageUrl,
      'imagePrompt': imagePrompt,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'weather': weather,
      'mood': mood,
    };
  }

  DiaryModel copyWith({
    String? id,
    String? userId,
    String? content,
    String? summary,
    EmotionScore? emotions,
    String? gardenImageUrl,
    String? imagePrompt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? weather,
    String? mood,
  }) {
    return DiaryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      emotions: emotions ?? this.emotions,
      gardenImageUrl: gardenImageUrl ?? this.gardenImageUrl,
      imagePrompt: imagePrompt ?? this.imagePrompt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weather: weather ?? this.weather,
      mood: mood ?? this.mood,
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt).inDays;
    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    return '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
  }
}
