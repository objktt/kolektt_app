import 'package:flutter/cupertino.dart';

class AppTypography {
  static const String fontFamily = 'Pretendard';

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 32,
    color: CupertinoColors.label,
  );
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: CupertinoColors.label,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: CupertinoColors.label,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: CupertinoColors.secondaryLabel,
  );
  // ... 필요시 추가 스타일
}
