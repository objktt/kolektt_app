import 'package:flutter/cupertino.dart';

class OnboardingPage2 extends StatelessWidget {
  final VoidCallback? onNext;
  const OnboardingPage2({super.key, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '아티스트를 쉽게 찾고\n팔로우하세요',
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
          '좋아하는 아티스트를 팔로우하면\n새 앨범 소식을 받아볼 수 있어요.',
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
