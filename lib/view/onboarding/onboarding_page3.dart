import 'package:flutter/cupertino.dart';

class OnboardingPage3 extends StatelessWidget {
  final VoidCallback? onStart;
  const OnboardingPage3({super.key, this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '나만의 컬렉션 완성하기',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 32,
            color: Color(0xFF0E0E10),
            height: 44 / 32,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          '내 취향에 맞는 앨범을 추가하고\n컬렉션을 완성해보세요.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0xFF575758),
            height: 22 / 16,
            letterSpacing: 0.32,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: CupertinoButton(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(8),
            padding: EdgeInsets.zero,
            onPressed: onStart,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '시작하기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF0036FF),
                    letterSpacing: 0.32,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: Color(0xFF0036FF),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
