import 'package:flutter/foundation.dart';
import '../../data/models/diary_model.dart';
import '../../data/services/diary_service.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum DiaryStatus { initial, loading, success, error }

class DiaryProvider extends ChangeNotifier {
  final DiaryService _diaryService = DiaryService();

  DiaryStatus _status = DiaryStatus.initial;
  DiaryStatus _createStatus = DiaryStatus.initial;

  List<DiaryModel> _diaries = [];
  DiaryModel? _todayDiary;
  String? _errorMessage;
  String? _createErrorMessage;

  // 현재 앱 테마 색상 (감정 기반)
  Color _themeColor = AppTheme.defaultSeedColor;

  DiaryStatus get status => _status;
  DiaryStatus get createStatus => _createStatus;
  List<DiaryModel> get diaries => _diaries;
  DiaryModel? get todayDiary => _todayDiary;
  String? get errorMessage => _errorMessage;
  String? get createErrorMessage => _createErrorMessage;
  Color get themeColor => _themeColor;
  bool get isCreating => _createStatus == DiaryStatus.loading;

  /// 일기 목록 실시간 스트림 시작
  void startListening(String userId) {
    _status = DiaryStatus.loading;
    notifyListeners();

    _diaryService.getDiariesStream(userId).listen(
      (diaries) {
        _diaries = diaries;
        _status = DiaryStatus.success;
        _updateTodayDiary();
        _updateThemeColor();
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = '일기를 불러오는 중 오류가 발생했습니다.';
        _status = DiaryStatus.error;
        notifyListeners();
      },
    );
  }

  /// 오늘의 일기 업데이트
  void _updateTodayDiary() {
    final today = DateTime.now();
    _todayDiary = _diaries.firstWhere(
      (d) =>
          d.createdAt.year == today.year &&
          d.createdAt.month == today.month &&
          d.createdAt.day == today.day,
      orElse: () => _diaries.isNotEmpty ? _diaries.first : DiaryModel(
        id: '',
        userId: '',
        content: '',
        emotions: const EmotionScore(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // 오늘 일기가 없으면 null로
    if (_todayDiary?.id.isEmpty == true) {
      _todayDiary = null;
    }
  }

  /// 최신 일기의 감정에 따라 테마 색상 업데이트
  void _updateThemeColor() {
    if (_diaries.isNotEmpty) {
      final latestDiary = _diaries.first;
      final dominantEmotion = latestDiary.emotions.dominantEmotion;
      _themeColor = AppTheme.getSeedColorForEmotion(dominantEmotion);
    } else {
      _themeColor = AppTheme.defaultSeedColor;
    }
  }

  /// 새 일기 작성 (AI 분석 + 이미지 생성)
  Future<DiaryModel?> createDiary({
    required String userId,
    required String content,
    String weather = '',
  }) async {
    _createStatus = DiaryStatus.loading;
    _createErrorMessage = null;
    notifyListeners();

    try {
      final diary = await _diaryService.createDiary(
        userId: userId,
        content: content,
        weather: weather,
      );

      _createStatus = DiaryStatus.success;
      notifyListeners();
      return diary;
    } catch (e) {
      _createErrorMessage = e.toString().replaceAll('Exception: ', '');
      _createStatus = DiaryStatus.error;
      notifyListeners();
      return null;
    }
  }

  /// 일기 삭제
  Future<void> deleteDiary(String userId, DiaryModel diary) async {
    try {
      await _diaryService.deleteDiary(userId, diary);
      _diaries.removeWhere((d) => d.id == diary.id);
      _updateTodayDiary();
      _updateThemeColor();
      notifyListeners();
    } catch (e) {
      _errorMessage = '일기 삭제 중 오류가 발생했습니다.';
      notifyListeners();
    }
  }

  void resetCreateStatus() {
    _createStatus = DiaryStatus.initial;
    _createErrorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
