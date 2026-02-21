import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/diary_model.dart';
import '../../core/constants/app_constants.dart';

class AiService {
  late final Dio _dio;
  late final String _apiKey;

  AiService() {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.openAiBaseUrl,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
  }

  /// 일기 텍스트를 분석해 감정 점수(1~5) 및 요약 반환
  Future<Map<String, dynamic>> analyzeDiary(String diaryContent) async {
    if (_apiKey.isEmpty || _apiKey == 'your_openai_api_key_here') {
      throw Exception('OpenAI API 키가 설정되지 않았습니다. .env 파일을 확인해주세요.');
    }

    const systemPrompt = '''
당신은 감정 분석 전문가입니다. 사용자가 작성한 일기를 읽고 다음 8가지 감정을 각각 1~5 점수로 평가해주세요.

감정 목록:
- joy (기쁨): 행복하고 즐거운 감정
- sadness (슬픔): 슬프고 우울한 감정  
- anger (분노): 화나고 짜증나는 감정
- calm (평온): 평화롭고 안정된 감정
- anxiety (불안): 걱정되고 긴장된 감정
- surprise (놀람): 뜻밖이고 놀라운 감정
- boredom (지루함): 심심하고 무기력한 감정
- trust (신뢰): 믿음직하고 안심되는 감정

점수 기준:
1: 거의 없음, 2: 약간, 3: 보통, 4: 강함, 5: 매우 강함

반드시 다음 JSON 형식으로만 응답하세요:
{
  "emotions": {
    "joy": <1-5>,
    "sadness": <1-5>,
    "anger": <1-5>,
    "calm": <1-5>,
    "anxiety": <1-5>,
    "surprise": <1-5>,
    "boredom": <1-5>,
    "trust": <1-5>
  },
  "summary": "<일기의 핵심을 2-3문장으로 요약>",
  "mood": "<전체적인 기분을 한 단어로>",
  "gardenDescription": "<감정 수치를 반영한 정원의 분위기를 한국어로 2-3문장 묘사>"
}
''';

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': AppConstants.gptModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': '다음 일기를 분석해주세요:\n\n$diaryContent'},
          ],
          'temperature': 0.3,
          'response_format': {'type': 'json_object'},
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      final parsed = jsonDecode(content) as Map<String, dynamic>;
      return parsed;
    } on DioException catch (e) {
      throw _handleDioError(e, '감정 분석');
    }
  }

  /// 감정 점수를 기반으로 정원 이미지 프롬프트 생성 후 DALL-E로 이미지 URL 반환
  Future<String> generateGardenImage(EmotionScore emotions, String gardenDescription) async {
    if (_apiKey.isEmpty || _apiKey == 'your_openai_api_key_here') {
      throw Exception('OpenAI API 키가 설정되지 않았습니다.');
    }

    final prompt = _buildImagePrompt(emotions, gardenDescription);

    try {
      final response = await _dio.post(
        '/images/generations',
        data: {
          'model': AppConstants.dalleModel,
          'prompt': prompt,
          'n': 1,
          'size': AppConstants.dalleImageSize,
          'quality': AppConstants.dalleImageQuality,
          'style': 'vivid',
        },
      );

      final imageUrl = response.data['data'][0]['url'] as String;
      return imageUrl;
    } on DioException catch (e) {
      throw _handleDioError(e, '정원 이미지 생성');
    }
  }

  /// 감정 수치에서 DALL-E 이미지 프롬프트 자동 생성
  String _buildImagePrompt(EmotionScore emotions, String gardenDescription) {
    final buffer = StringBuffer();

    // 기본 스타일 설정
    buffer.write(
      'A cute, whimsical garden illustration in a pastel watercolor style, '
      'rounded and soft aesthetic, Studio Ghibli inspired, high quality digital art. ',
    );

    // 감정 수치에 따른 정원 요소 추가
    // 기쁨 (joy)
    if (emotions.joy >= 4) {
      buffer.write('Bright golden sunlight streaming through, colorful butterflies dancing, '
          'vibrant blooming flowers everywhere, cheerful fairy lights. ');
    } else if (emotions.joy >= 2) {
      buffer.write('Warm gentle sunlight, some colorful flowers blooming. ');
    }

    // 슬픔 (sadness)
    if (emotions.sadness >= 4) {
      buffer.write('Misty and melancholic atmosphere, pale blue flowers like forget-me-nots, '
          'soft rain droplets on petals, quiet and still pond. ');
    } else if (emotions.sadness >= 2) {
      buffer.write('A gentle misty veil over the garden, pale lavender flowers. ');
    }

    // 분노 (anger)
    if (emotions.anger >= 4) {
      buffer.write('Fierce red roses with thorns, dramatic crimson sunset sky, '
          'bold and intense colors. ');
    } else if (emotions.anger >= 2) {
      buffer.write('Some vivid red poppies, warm orange tones. ');
    }

    // 평온 (calm)
    if (emotions.calm >= 4) {
      buffer.write('Serene zen garden with smooth stones, gentle flowing stream, '
          'soft green moss, tranquil lily pond with koi fish. ');
    } else if (emotions.calm >= 2) {
      buffer.write('A peaceful corner with soft green plants, small stone path. ');
    }

    // 불안 (anxiety)
    if (emotions.anxiety >= 4) {
      buffer.write('Tangled ivy vines, overgrown paths with hidden secrets, '
          'mysterious purple and indigo flowers, moonlit shadows. ');
    } else if (emotions.anxiety >= 2) {
      buffer.write('Some winding paths through dense foliage. ');
    }

    // 놀람 (surprise)
    if (emotions.surprise >= 4) {
      buffer.write('Magical glowing mushrooms, surprise pockets of colorful wildflowers, '
          'whimsical secret doors in tree trunks, fireflies. ');
    } else if (emotions.surprise >= 2) {
      buffer.write('Unexpected colorful wildflower patches, cute hidden details. ');
    }

    // 지루함 (boredom)
    if (emotions.boredom >= 4) {
      buffer.write('Monotone grey-green tones, withered autumn leaves falling, '
          'empty swings, faded flowers. ');
    } else if (emotions.boredom >= 2) {
      buffer.write('Some quiet empty spaces, muted tones. ');
    }

    // 신뢰 (trust)
    if (emotions.trust >= 4) {
      buffer.write('Ancient oak trees with warm glowing lights, cozy garden cottage, '
          'friendly garden creatures like hedgehogs and rabbits, warm amber lanterns. ');
    } else if (emotions.trust >= 2) {
      buffer.write('Solid green hedges, a warm lantern path, welcoming atmosphere. ');
    }

    // 전체 분위기 묘사 추가 (한국어는 제거하고 영어로 변환된 설명 추가)
    buffer.write('Beautiful and dreamy garden scene, cinematic lighting, no text, no people, '
        'ultra detailed illustration.');

    return buffer.toString();
  }

  /// 프롬프트만 생성 (저장용)
  String buildPromptForRecord(EmotionScore emotions, String gardenDescription) {
    return _buildImagePrompt(emotions, gardenDescription);
  }

  /// Dio 에러 처리
  Exception _handleDioError(DioException e, String operation) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      final errorMessage = data?['error']?['message'] ?? '알 수 없는 오류';

      if (statusCode == 401) {
        return Exception('API 키가 올바르지 않습니다. .env 파일을 확인해주세요.');
      } else if (statusCode == 429) {
        return Exception('API 요청 한도를 초과했습니다. 잠시 후 다시 시도해주세요.');
      } else if (statusCode == 500) {
        return Exception('OpenAI 서버 오류입니다. 잠시 후 다시 시도해주세요.');
      }
      return Exception('$operation 실패 ($statusCode): $errorMessage');
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('요청 시간이 초과되었습니다. 네트워크를 확인해주세요.');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('인터넷 연결을 확인해주세요.');
    }
    return Exception('$operation 중 오류가 발생했습니다: ${e.message}');
  }
}
