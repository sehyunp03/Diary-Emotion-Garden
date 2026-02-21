import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/utils/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/diary_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 상태바 스타일
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 화면 방향 고정 (세로)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // .env 파일 로드
  await dotenv.load(fileName: '.env');

  // 날짜 형식 초기화 (한국어)
  await initializeDateFormatting('ko_KR', null);

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GardenDiaryApp());
}

class GardenDiaryApp extends StatelessWidget {
  const GardenDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
      ],
      child: Consumer2<AuthProvider, DiaryProvider>(
        builder: (context, authProvider, diaryProvider, _) {
          return AnimatedTheme(
            duration: const Duration(milliseconds: 600),
            data: AppTheme.getTheme(diaryProvider.themeColor),
            child: MaterialApp(
              title: 'Garden Diary',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getTheme(diaryProvider.themeColor),
              home: _AppRouter(authProvider: authProvider),
            ),
          );
        },
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  final AuthProvider authProvider;

  const _AppRouter({required this.authProvider});

  @override
  Widget build(BuildContext context) {
    switch (authProvider.status) {
      case AuthStatus.initial:
        return _SplashScreen();

      case AuthStatus.loading:
        return _SplashScreen();

      case AuthStatus.authenticated:
        return const HomeScreen();

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🌿', style: TextStyle(fontSize: 52)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Garden Diary',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(
              color: const Color(0xFF4CAF50),
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
