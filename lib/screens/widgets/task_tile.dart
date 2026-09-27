import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_app/models/task_model.dart';
import 'package:task_manager_app/screens/theme.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const TaskTile(
    this.task, {
    super.key,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor(task.color);
    final completed = task.isCompleted == 1;
    final surface = Get.isDarkMode ? darkHeaderClr : Colors.white;

    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Get.isDarkMode ? Colors.white12 : lightBorderClr,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: completed ? greenClr : accentColor),
              SizedBox(
                width: 92,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 18,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        task.startTime,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: bodyTextStyle.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 12,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: Get.isDarkMode
                            ? Colors.white24
                            : const Color(0xFFCBD0D8),
                      ),
                      Text(
                        task.endTime,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: body2TextStyle.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Get.isDarkMode ? Colors.white12 : lightBorderClr,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: titleTextStle.copyWith(
                                fontSize: 16,
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: completed
                                    ? body2TextStyle.color
                                    : titleTextStle.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _statusLabel(completed, accentColor),
                        ],
                      ),
                      if (task.note.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          task.note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: body2TextStyle,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (task.repeat != 'None')
                            _metadata(Icons.repeat_rounded, task.repeat),
                          _metadata(
                            Icons.notifications_none_rounded,
                            '${task.remind} min before',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  onPressed: onToggle,
                  tooltip: completed ? 'Reopen task' : 'Complete task',
                  icon: Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: completed ? greenClr : accentColor,
                    size: 27,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusLabel(bool completed, Color accentColor) {
    final color = completed ? greenClr : accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: Get.isDarkMode ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        completed ? 'Done' : 'Open',
        style: bodyTextStyle.copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _metadata(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Get.isDarkMode ? Colors.white54 : const Color(0xFF7A8290),
        ),
        const SizedBox(width: 4),
        Text(label, style: body2TextStyle.copyWith(fontSize: 12)),
      ],
    );
  }

  Color _getAccentColor(int number) {
    switch (number) {
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
