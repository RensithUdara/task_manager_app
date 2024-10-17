import 'package:flutter/material.dart';
import 'package:task_manager_app/screens/theme.dart';

class CustomButton extends StatelessWidget {
  final Function? onTap;
  final String? label;

  CustomButton({
    this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Container(
        height: 50,
        width: 130,
        decoration: BoxDecoration(
          color: primaryClr,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label ?? "",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
