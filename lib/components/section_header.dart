import 'package:flutter/cupertino.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool showMore;
  final VoidCallback? onShowMore;
  const SectionHeader({
    super.key,
    required this.title,
    this.showMore = false,
    this.onShowMore,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(title, style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle),
          const Spacer(),
          if (showMore)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onShowMore,
              child: const Row(
                children: [
                  Text("더보기", style: TextStyle(fontSize: 14)),
                  Icon(CupertinoIcons.chevron_right, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
