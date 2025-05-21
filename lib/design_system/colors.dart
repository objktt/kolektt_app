import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color primary = Color(0xFF0036FF);
  static const Color secondary = Color(0xFF00C2FF);
  static const Color background = CupertinoColors.systemBackground;
  static const Color surface = CupertinoColors.systemGrey6;
  static const Color error = CupertinoColors.systemRed;
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color info = Color(0xFF0091EA);
  static const Color divider = CupertinoColors.systemGrey4;
  // 다크/라이트 대응 예시
  static const CupertinoDynamicColor dynamicBackground =
      CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.systemBackground,
    darkColor: CupertinoColors.black,
  );
  // ... 필요시 추가 컬러
}
