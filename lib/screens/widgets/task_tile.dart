import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_manager_app/models/task_model.dart';
import 'package:task_manager_app/screens/size_config.dart';
import 'package:task_manager_app/screens/theme.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile(this.task, {super.key});

  @override
  Widget build(BuildContext context) {
    final accentColor = _getBGClr(task.color);
    final completed = task.isCompleted == 1;

    return Container(
      width: SizeConfig.screenWidth,
      margin: EdgeInsets.fromLTRB(
        getProportionateScreenWidth(20),
        0,
        getProportionateScreenWidth(20),
        getProportionateScreenHeight(12),
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: completed
              ? greenClr.withValues(alpha: 0.35)
              : accentColor.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Get.isDarkMode ? 0.18 : 0.05,
            ),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 82,
            decoration: BoxDecoration(
              color: completed ? greenClr : accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Get.isDarkMode ? Colors.white : darkGreyClr,
                            decoration: completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: completed ? greenClr : accentColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoPill(
                      icon: Icons.schedule,
                      label: '${task.startTime} - ${task.endTime}',
                    ),
                    if (task.repeat != 'None')
                      _infoPill(
                        icon: Icons.repeat,
                        label: task.repeat,
                      ),
                    _infoPill(
                      icon: Icons.notifications_none,
                      label: '${task.remind}m',
                    ),
                  ],
                ),
                if (task.note.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    task.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: body2TextStyle,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPill({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Get.isDarkMode ? Colors.white70 : null),
          const SizedBox(width: 5),
          Text(label, style: body2TextStyle.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Color _getBGClr(int no) {
    switch (no) {
      case 0:
        return purpleClr;
      case 1:
        return pinkClr;
      case 2:
        return yellowClr;
      default:
        return primaryClr;
    }
  }
}
