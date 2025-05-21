import 'package:flutter/cupertino.dart';

class GenreButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;

  const GenreButton(
      {super.key,
        required this.title,
        required this.isSelected,
        required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isSelected ? CupertinoColors.black : CupertinoColors.systemGrey4,
      borderRadius: BorderRadius.circular(20),
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? CupertinoColors.white : CupertinoColors.black,
        ),
      ),
    );
  }
}
