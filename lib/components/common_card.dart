import 'package:flutter/material.dart';

class CommonCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final EdgeInsetsGeometry padding;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const CommonCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.radius = 16,
    this.padding = const EdgeInsets.all(16),
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
