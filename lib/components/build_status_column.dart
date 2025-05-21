import 'package:flutter/cupertino.dart';
import '../design_system/typography.dart';
import '../design_system/colors.dart';

Widget buildStatColumn(String value, String label) {
  return Column(
    children: [
      Text(
        value,
        style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: AppTypography.caption.copyWith(color: AppColors.divider),
      ),
    ],
  );
}
