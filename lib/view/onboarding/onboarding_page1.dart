import 'package:flutter/cupertino.dart';

class OnboardingPage1 extends StatelessWidget {
  final VoidCallback? onNext;
  const OnboardingPage1({super.key, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '음반을 쉽게 기록하고\n관리하세요',
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
          '앨범 커버를 촬영하면\n자동으로 정보를 인식해요.',
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
            onPressed: onNext,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '다음',
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
