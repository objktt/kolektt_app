import 'package:flutter/cupertino.dart';
import 'onboarding_page1.dart';
import 'onboarding_page2.dart';
import 'onboarding_page3.dart';
import 'permission_page.dart';
import '../auth/signup_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      // 마지막 페이지: 온보딩 종료 후 권한 요청 화면으로 이동
      Navigator.of(context)
          .push(
        CupertinoPageRoute(
          builder: (_) => const PermissionPage(),
        ),
      )
          .then((result) {
        if (result == true) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (_) => const SignupPage()),
          );
        }
      });
    }
  }

  Widget _buildProgressBar(int page, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => Container(
          width: 30,
          height: 6,
          margin: EdgeInsets.only(right: index < total - 1 ? 8 : 0),
          decoration: BoxDecoration(
            color: index <= page
                ? const Color(0xFF2654FF)
                : const Color(0xFFE6E9EB),
            borderRadius: BorderRadius.circular(38),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(int page) {
    final List<String> images = [
      'assets/images/1_2_1.png',
      'assets/images/1_2_2.png',
      'assets/images/1_2_3.png',
    ];
    final List<String> semantics = [
      '온보딩 일러스트',
      '아티스트 일러스트',
      '컬렉션 일러스트',
    ];
    return Image.asset(
      images[page],
      width: 261,
      height: 295,
      fit: BoxFit.contain,
      semanticLabel: semantics[page],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressBar = _buildProgressBar(_currentPage, 3);
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            _buildIllustration(_currentPage),
            const SizedBox(height: 24),
            progressBar,
            const SizedBox(height: 32),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  OnboardingPage1(onNext: _nextPage),
                  OnboardingPage2(onNext: _nextPage),
                  OnboardingPage3(onStart: _nextPage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
