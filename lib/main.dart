import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'firebase_options.dart';

import 'providers/user_provider.dart';
import 'repositories/user_repository.dart';
import 'services/fcm_service.dart';
import 'utils/calendar_service.dart';

import 'theme.dart';
import 'widgets/custom_button.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

// 전역 플래그로 Firebase 사용 여부를 확인 가능하도록 설정
bool isFirebaseEnabled = false;

bool isCloudFunctionsEnabled = true;

// --- Riverpod Providers (전역 공유 상태 관리) ---

// 1. 대화 스타일 세그먼트 상태 공급자 (0: 반말, 1: 높임말)
class SelectedStyle extends Notifier<int> {
  UserRepository get _repo => ref.read(userRepositoryProvider);

  @override
  int build() {
    _init();
    return 0;
  }

  Future<void> _init() async {
    final settings = await _repo.getUserSettings();
    if (settings != null && settings['selectedStyle'] != null) {
      state = settings['selectedStyle'] as int;
    }
  }

  Future<void> select(int val) async {
    state = val;
    await _repo.saveUserSettings(selectedStyle: val);
  }
}
final selectedStyleProvider = NotifierProvider<SelectedStyle, int>(SelectedStyle.new);

// 2. 푸시 알림 설정 토글 상태 공급자
class ToggleState extends Notifier<bool> {
  UserRepository get _repo => ref.read(userRepositoryProvider);

  @override
  bool build() {
    _init();
    return false;
  }

  Future<void> _init() async {
    final settings = await _repo.getUserSettings();
    if (settings != null && settings['notificationEnabled'] != null) {
      state = settings['notificationEnabled'] as bool;
    }
  }

  Future<void> toggle(bool val) async {
    state = val;
    await _repo.saveUserSettings(notificationEnabled: val);
  }
}
final toggleStateProvider = NotifierProvider<ToggleState, bool>(ToggleState.new);


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseEnabled = true;
    debugPrint('Firebase: Successfully initialized');

    // 로컬 에뮬레이터 설정 (Mac AirPlay Receiver의 5001 포트 충돌 방지를 위해 5002 포트 사용)
    if (kDebugMode) {
      final host = defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
      FirebaseFunctions.instance.useFunctionsEmulator(host, 5002);
      debugPrint('FirebaseFunctions: Using local emulator at $host:5002');
    }

    // 익명 로그인 수행
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
      debugPrint('Firebase: Anonymous sign-in success. UID = ${auth.currentUser?.uid}');
    } else {
      debugPrint('Firebase: Already signed in. UID = ${auth.currentUser?.uid}');
    }

    // FCM 서비스 초기화 및 토큰 동기화
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      await FcmService.initialize(uid: uid);

      // 오늘 캘린더 일정 Firestore 동기화 (모바일에서만 동작)
      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
        final todayEvents = await CalendarService.getTodayEvents();
        await FcmService.syncTodayEvents(uid: uid, events: todayEvents);
      }
    }
  } catch (e) {
    debugPrint('Firebase: Initialization failed. Operating in mock mode. Error: $e');
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Majung App',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.mainColor,
          primary: AppColors.mainColor,
        ),
        scaffoldBackgroundColor: AppColors.white,
        useMaterial3: true,
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends ConsumerWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          '마중 개발자 런처',
          style: AppTextStyle.body2B.copyWith(color: AppColors.grayScale9),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.gray2,
            height: 1.0,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 앱 로고 영역 시각 효과 대체
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.subColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '👋',
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '마중(Majung) 애플리케이션',
                textAlign: TextAlign.center,
                style: AppTextStyle.body1.copyWith(
                  color: AppColors.grayScale9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '화면 및 흐름 검증을 위한 런처입니다.\n원하는 진입 방법을 선택해 주세요.',
                textAlign: TextAlign.center,
                style: AppTextStyle.caption1.copyWith(
                  color: AppColors.gray4,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              // 1. 처음부터 흐름 시작하기 (온보딩 -> 홈)
              CustomButton(
                label: '✨ 처음부터 시작하기 (온보딩 ➡️ 홈)',
                isFullWidth: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // 2. 홈 화면으로 바로가기 (모든 기능 연결됨)
              CustomButton(
                label: '🏠 홈 화면으로 바로가기 (모든 기능 연결됨)',
                isFullWidth: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                      settings: const RouteSettings(name: '/home'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
