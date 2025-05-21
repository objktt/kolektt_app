import 'package:flutter/cupertino.dart';

import '../model/activity_type.dart';
import '../design_system/typography.dart';
import '../design_system/colors.dart';

class ActivityCard extends StatelessWidget {
  final ActivityType type;
  final String title;
  final String subtitle;
  final String date;
  final String? status;
  final Color? statusColor;

  const ActivityCard({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    this.status,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 앨범 커버 (임시 이미지)
          Container(
            width: 50,
            height: 50,
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            child: const Icon(CupertinoIcons.music_note,
                color: CupertinoColors.systemGrey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.divider)),
                Text(subtitle,
                    style: AppTypography.body
                        .copyWith(color: CupertinoColors.label)),
                if (status != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          (statusColor ?? AppColors.primary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(status!,
                        style: AppTypography.caption
                            .copyWith(color: statusColor ?? AppColors.primary)),
                  ),
              ],
            ),
          ),
          Text(date,
              style: AppTypography.caption.copyWith(color: AppColors.divider)),
        ],
      ),
    );
  }
}
