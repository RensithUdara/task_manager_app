import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final IconData? icon;
  final double? width;

  const CustomButton({
    super.key,
    this.onTap,
    required this.label,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final button = icon == null
        ? FilledButton(onPressed: onTap, child: Text(label))
        : FilledButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 19),
            label: Text(label),
          );

    return SizedBox(width: width, height: 50, child: button);
  }
}
