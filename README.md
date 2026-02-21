# 🌿 Garden Diary - AI 감정 분석 기반 정원 생성 일기 앱

감정을 분석하여 나만의 AI 정원을 만들어주는 Flutter 일기 앱입니다.

## ✨ 주요 기능

- **구글 소셜 로그인**: Firebase Authentication + Google Sign-In
- **AI 감정 분석**: GPT-4o가 일기를 8가지 감정으로 분류 (기쁨/슬픔/분노/평온/불안/놀람/지루함/신뢰)
- **AI 정원 이미지 생성**: DALL-E 3가 감정 수치를 기반으로 맞춤 정원 이미지 생성
- **다이나믹 테마**: 감정에 따라 앱 색상이 은은하게 변화
- **귀여운 UI**: Material 3 + 둥글둥글한 스타일, 부드러운 애니메이션

## 🛠 기술 스택

| 항목 | 기술 |
|------|------|
| Framework | Flutter (Dart) |
| 인증 | Firebase Auth + Google Sign-In |
| 데이터베이스 | Cloud Firestore |
| 파일 저장 | Firebase Storage |
| AI 감정 분석 | OpenAI GPT-4o |
| AI 이미지 생성 | OpenAI DALL-E 3 |
| 상태 관리 | Provider |
| UI 애니메이션 | flutter_animate |
| 이미지 캐싱 | cached_network_image |
| HTTP 클라이언트 | Dio |

## 📁 프로젝트 구조

```
lib/
├── core/
│   ├── constants/       # 앱 상수 (감정 목록, API 설정 등)
│   ├── theme/           # Material 3 테마, 감정별 색상
│   └── utils/           # Firebase 옵션
├── data/
│   ├── models/          # 데이터 모델 (UserModel, DiaryModel, EmotionScore)
│   └── services/        # 서비스 레이어
│       ├── auth_service.dart    # Firebase 인증 + 구글 로그인
│       ├── ai_service.dart      # OpenAI GPT-4o + DALL-E 3
│       └── diary_service.dart   # Firestore CRUD + Storage
├── presentation/
│   ├── providers/       # Provider 상태 관리
│   │   ├── auth_provider.dart
│   │   └── diary_provider.dart
│   ├── screens/
│   │   ├── auth/        # 로그인 화면
│   │   ├── home/        # 메인 홈 (정원 히어로 + 일기 목록)
│   │   └── diary/       # 일기 작성, 상세 화면
│   └── widgets/         # 재사용 컴포넌트
│       ├── garden_hero.dart     # 정원 이미지 히어로 섹션
│       ├── diary_card.dart      # 일기 목록 카드
│       ├── emotion_bar.dart     # 감정 수치 막대 그래프
│       └── loading_overlay.dart # AI 처리 중 오버레이
└── main.dart
```

## 🚀 시작하기

### 1. Firebase 프로젝트 설정

1. [Firebase Console](https://console.firebase.google.com)에서 새 프로젝트 생성
2. **Authentication** → Google 로그인 활성화
3. **Firestore Database** 생성 (테스트 모드로 시작)
4. **Storage** 활성화

#### Android 설정
- `google-services.json` 다운로드 → `android/app/` 폴더에 배치
- `android/app/google-services.json.example`을 참고하세요

#### iOS 설정
- `GoogleService-Info.plist` 다운로드 → `ios/Runner/` 폴더에 배치
- `ios/Runner/Info.plist`의 `YOUR_REVERSED_CLIENT_ID`와 `YOUR_IOS_CLIENT_ID`를 실제 값으로 교체

### 2. FlutterFire CLI로 자동 설정 (권장)

```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 설정 자동 생성
flutterfire configure
```

이 명령어가 `lib/core/utils/firebase_options.dart`를 자동으로 업데이트합니다.

### 3. OpenAI API 키 설정

`.env` 파일에 API 키를 입력하세요:

```env
OPENAI_API_KEY=sk-your-actual-api-key-here
```

⚠️ `.env` 파일은 절대 Git에 커밋하지 마세요!

### 4. 의존성 설치 및 실행

```bash
cd garden_diary
flutter pub get
flutter run
```

## 📊 Firestore 데이터 구조

```
users/
  {userId}/
    - email: string
    - displayName: string
    - photoUrl: string?
    - createdAt: timestamp
    - updatedAt: timestamp
    - totalDiaries: number
    - preferredEmotion: string

    diaries/
      {diaryId}/
        - userId: string
        - content: string
        - summary: string        ← AI 요약
        - emotions: {            ← 8가지 감정 점수 (1-5)
            joy, sadness, anger, calm,
            anxiety, surprise, boredom, trust
          }
        - gardenImageUrl: string ← Firebase Storage URL
        - imagePrompt: string    ← DALL-E 프롬프트
        - createdAt: timestamp
        - updatedAt: timestamp
        - weather: string
        - mood: string           ← 한 단어 기분 요약
```

## 🎨 감정별 테마 색상

| 감정 | 색상 | 정원 특징 |
|------|------|----------|
| 기쁨 😊 | 황금 노랑 | 햇살, 나비, 형형색색 꽃 |
| 슬픔 😢 | 차분한 파랑 | 안개, 물망초, 고요한 연못 |
| 분노 😠 | 붉은 오렌지 | 장미 가시, 드라마틱한 석양 |
| 평온 😌 | 초록 | 젠 정원, 잉어 연못, 이끼 |
| 불안 😰 | 보라 | 넝쿨, 달빛 그림자 |
| 놀람 😲 | 주황 | 반짝이는 버섯, 반딧불이 |
| 지루함 😑 | 회색 | 단조로운 톤, 시든 잎 |
| 신뢰 🤝 | 따뜻한 초록 | 오래된 참나무, 따뜻한 등불 |

## ⚠️ 주의사항

- OpenAI DALL-E 3 이미지 생성에는 시간이 소요될 수 있습니다 (약 20-60초)
- Firebase Storage 비용이 발생할 수 있습니다
- OpenAI API 사용량에 따른 비용이 발생합니다

## 📄 라이선스

MIT License
