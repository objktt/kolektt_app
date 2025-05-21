import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'content_view.dart';
import 'login_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingComplete = prefs.getBool('isOnboardingComplete') ?? false;

    if (!isOnboardingComplete) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (_) => isLoggedIn ? const ContentView() : const LoginView(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness =
        CupertinoTheme.of(context).brightness ?? Brightness.light;
    final bool isDark = brightness == Brightness.dark;
    final Color backgroundColor =
        isDark ? CupertinoColors.black : const Color(0xFF0036FF);
    const Color textColor = CupertinoColors.white;

    // 상태바 색상 동기화
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: backgroundColor,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              label: 'Kolektt 로고',
              header: true,
              child: const Text(
                'Kolektt',
                style: TextStyle(
                  fontFamily: 'VampiroOne',
                  fontWeight: FontWeight.normal,
                  fontSize: 48,
                  color: CupertinoColors.white,
                  height: 60 / 48, // Figma 기준
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: '앱 슬로건',
              child: const Text(
                '당신의 레코드 컬렉션,\n더 쉽게 더 즐겁게',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400, // Regular
                  fontSize: 18,
                  color: CupertinoColors.white,
                  height: 24 / 18, // Figma 기준
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
