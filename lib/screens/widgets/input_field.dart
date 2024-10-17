import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_app/screens/theme.dart';

class InputField extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final String hint;
  final Widget? widget;

  const InputField({
    required this.title,
    this.controller,
    required this.hint,
    this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleTextStle,
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(12.0),
              color: Get.isDarkMode ? Colors.black12 : Colors.white,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    autofocus: false,
                    cursorColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[600],
                    readOnly: widget != null,
                    controller: controller,
                    style: subTitleTextStle,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: subTitleTextStle.copyWith(
                        color: Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 5),
                    ),
                  ),
                ),
                widget ?? Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
