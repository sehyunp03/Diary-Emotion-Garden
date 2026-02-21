import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/diary_model.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';
import 'ai_service.dart';

class DiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AiService _aiService = AiService();
  final _uuid = const Uuid();

  /// 일기 생성 (AI 분석 + 이미지 생성 포함)
  Future<DiaryModel> createDiary({
    required String userId,
    required String content,
    String weather = '',
  }) async {
    // 1. AI 감정 분석
    final analysisResult = await _aiService.analyzeDiary(content);

    final emotionsMap = analysisResult['emotions'] as Map<String, dynamic>;
    final emotions = EmotionScore(
      joy: (emotionsMap['joy'] ?? 1).toInt(),
      sadness: (emotionsMap['sadness'] ?? 1).toInt(),
      anger: (emotionsMap['anger'] ?? 1).toInt(),
      calm: (emotionsMap['calm'] ?? 1).toInt(),
      anxiety: (emotionsMap['anxiety'] ?? 1).toInt(),
      surprise: (emotionsMap['surprise'] ?? 1).toInt(),
      boredom: (emotionsMap['boredom'] ?? 1).toInt(),
      trust: (emotionsMap['trust'] ?? 1).toInt(),
    );

    final summary = analysisResult['summary'] as String? ?? '';
    final mood = analysisResult['mood'] as String? ?? '평온';
    final gardenDescription =
        analysisResult['gardenDescription'] as String? ?? '';

    // 2. DALL-E 정원 이미지 생성
    final imageUrl =
        await _aiService.generateGardenImage(emotions, gardenDescription);

    // 3. 생성된 이미지를 Firebase Storage에 업로드
    final storedImageUrl = await _uploadImageToStorage(userId, imageUrl);

    // 4. 사용된 프롬프트 저장용
    final prompt = _aiService.buildPromptForRecord(emotions, gardenDescription);

    // 5. Firestore에 일기 저장
    final now = DateTime.now();
    final diaryId = _uuid.v4();

    final diary = DiaryModel(
      id: diaryId,
      userId: userId,
      content: content,
      summary: summary,
      emotions: emotions,
      gardenImageUrl: storedImageUrl,
      imagePrompt: prompt,
      createdAt: now,
      updatedAt: now,
      weather: weather,
      mood: mood,
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.diariesCollection)
        .doc(diaryId)
        .set(diary.toFirestore());

    // 6. 사용자 통계 업데이트
    await _updateUserStats(userId, emotions.dominantEmotion);

    return diary;
  }

  /// DALL-E가 반환한 임시 URL의 이미지를 Firebase Storage에 업로드
  Future<String> _uploadImageToStorage(
      String userId, String temporaryUrl) async {
    try {
      // 임시 파일로 다운로드
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final fileName = '${_uuid.v4()}.png';
      final filePath = '${tempDir.path}/$fileName';

      await dio.download(temporaryUrl, filePath);

      // Firebase Storage에 업로드
      final file = File(filePath);
      final storageRef = _storage
          .ref()
          .child(AppConstants.gardenImagesPath)
          .child(userId)
          .child(fileName);

      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // 임시 파일 삭제
      await file.delete();

      return downloadUrl;
    } catch (e) {
      // 업로드 실패 시 원본 URL 반환 (임시 만료될 수 있음)
      return temporaryUrl;
    }
  }

  /// 사용자 통계 업데이트
  Future<void> _updateUserStats(
      String userId, String dominantEmotion) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'totalDiaries': FieldValue.increment(1),
      'preferredEmotion': dominantEmotion,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// 사용자의 일기 목록 스트림 (최신순)
  Stream<List<DiaryModel>> getDiariesStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.diariesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DiaryModel.fromFirestore(doc)).toList());
  }

  /// 특정 날짜의 일기 조회
  Future<List<DiaryModel>> getDiariesByDate(
      String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.diariesCollection)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => DiaryModel.fromFirestore(doc)).toList();
  }

  /// 오늘의 최신 일기 가져오기
  Future<DiaryModel?> getTodayLatestDiary(String userId) async {
    final today = DateTime.now();
    final diaries = await getDiariesByDate(userId, today);
    return diaries.isEmpty ? null : diaries.first;
  }

  /// 일기 삭제
  Future<void> deleteDiary(String userId, DiaryModel diary) async {
    // Firestore에서 삭제
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.diariesCollection)
        .doc(diary.id)
        .delete();

    // Storage에서 이미지 삭제 (Firebase Storage URL인 경우)
    if (diary.gardenImageUrl.contains('firebase')) {
      try {
        final ref = _storage.refFromURL(diary.gardenImageUrl);
        await ref.delete();
      } catch (_) {}
    }

    // 사용자 통계 감소
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'totalDiaries': FieldValue.increment(-1),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// 사용자 정보 조회
  Future<UserModel?> getUserModel(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
}
