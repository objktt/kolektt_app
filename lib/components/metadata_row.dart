import 'package:flutter/cupertino.dart';
import '../design_system/typography.dart';

class MetadataRow extends StatelessWidget {
  final String title;
  final String value;

  const MetadataRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.caption,
          ),
          Text(
            value,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
