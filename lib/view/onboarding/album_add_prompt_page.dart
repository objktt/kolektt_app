import 'package:flutter/cupertino.dart';
import '../auto_album_detection_view.dart';

class AlbumAddPromptPage extends StatelessWidget {
  const AlbumAddPromptPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0036FF);
    const Color titleColor = Color(0xFF0E0E10);
    const Color descColor = Color(0xFF575758);
    const Color backgroundColor = CupertinoColors.white;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상태바 & 건너뛰기
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minSize: 0,
                  onPressed: () {
                    // TODO: 홈 또는 다음 화면으로 이동
                  },
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF3E3E40),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 일러스트 (임시 이미지, 실제 에셋 경로로 교체 필요)
            Center(
              child: Image.asset(
                'assets/images/1_4.png',
                width: 263,
                height: 277,
                fit: BoxFit.contain,
                semanticLabel: '앨범 추가 일러스트',
              ),
            ),
            const SizedBox(height: 40),
            // 타이틀
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                '첫 번째 레코드를 \n추가해 보세요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  color: Color(0xFF0E0E10),
                  height: 44 / 32,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 16),
            // 서브텍스트
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                '지금 컬렉션을 시작하면 음악 취향을 더 빠르게 \n분석해드립니다',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFF575758),
                  height: 22 / 16,
                  letterSpacing: 0.32,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const Spacer(),
            // 레코드 추가 버튼
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: CupertinoButton(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const AutoAlbumDetectionScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '레코드 추가',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: CupertinoColors.white,
                      letterSpacing: 0.32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
