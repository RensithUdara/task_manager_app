import 'package:flutter/material.dart';
import 'package:task_manager_app/screens/theme.dart';

class InputField extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final String hint;
  final Widget? widget;
  final IconData? icon;
  final int maxLines;
  final VoidCallback? onTap;

  const InputField({
    super.key,
    required this.title,
    this.controller,
    required this.hint,
    this.widget,
    this.icon,
    this.maxLines = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: bodyTextStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: widget != null || onTap != null,
            onTap: onTap,
            maxLines: maxLines,
            minLines: maxLines,
            cursorColor: primaryClr,
            style: bodyTextStyle.copyWith(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon == null ? null : Icon(icon, size: 20),
              suffixIcon: widget,
              alignLabelWithHint: maxLines > 1,
            ),
          ),
        ],
      ),
    );
  }
}
