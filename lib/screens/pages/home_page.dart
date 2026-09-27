// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/controllers/task_controller.dart';
import 'package:task_manager_app/models/task_model.dart';
import 'package:task_manager_app/screens/pages/add_task_page.dart';
import 'package:task_manager_app/screens/size_config.dart';
import 'package:task_manager_app/screens/theme.dart';
import 'package:task_manager_app/screens/widgets/task_tile.dart';
import 'package:task_manager_app/services/notification_services.dart';
import 'package:task_manager_app/services/theme_services.dart';

enum _TaskView { all, open, done }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final taskController = Get.put(TaskController());
  final TextEditingController searchController = TextEditingController();
  final NotifyHelper notifyHelper = NotifyHelper();

  DateTime selectedDate = DateTime.now();
  Timer? autoRefreshTimer;
  _TaskView selectedView = _TaskView.all;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    notifyHelper.initializeNotification();
    searchController.addListener(() {
      setState(() {
        searchTerm = searchController.text.trim().toLowerCase();
      });
    });

    autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      taskController.getTasks();
    });
  }

  @override
  void dispose() {
    autoRefreshTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: appBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddTask,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New task'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                addTaskBar(),
                summaryPanel(),
                searchAndFilters(),
                dateBar(),
                const SizedBox(height: 12),
                showTasks(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      toolbarHeight: 72,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Container(
          decoration: BoxDecoration(
            color: primaryClr,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.done_all_rounded, color: Colors.white),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TaskFlow',
            style: headingTextStyle.copyWith(fontSize: 20),
          ),
          Text(
            'Plan with clarity',
            style: body2TextStyle.copyWith(fontSize: 12),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Switch theme',
          onPressed: () {
            ThemeService().switchTheme();
            notifyHelper.displayNotification(
              title: 'Theme changed',
              body: Get.isDarkMode
                  ? 'Light theme activated.'
                  : 'Dark theme activated.',
            );
          },
          icon: Icon(
            Get.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 20),
          child: CircleAvatar(
            radius: 19,
            backgroundColor:
                primaryClr.withValues(alpha: Get.isDarkMode ? 0.24 : 0.12),
            child: const Icon(Icons.person_outline_rounded, color: primaryClr),
          ),
        ),
      ],
    );
  }

  Widget addTaskBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s focus',
                  style: body2TextStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: primaryClr,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, MMM d').format(DateTime.now()),
                  style: headingTextStyle.copyWith(fontSize: 26),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryPanel() {
    return Obx(() {
      final dayTasks = tasksForDate(taskController.taskList);
      final completed = dayTasks.where((task) => task.isCompleted == 1).length;
      final open = dayTasks.length - completed;
      final progress = dayTasks.isEmpty ? 0.0 : completed / dayTasks.length;
      final pendingTasks = dayTasks.where((task) => task.isCompleted == 0);
      final nextTask = pendingTasks.isEmpty ? null : pendingTasks.first;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.isDarkMode
              ? const Color(0xFF232A36)
              : const Color(0xFF222B45),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF222B45).withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dayTasks.isEmpty
                        ? 'Plan this day'
                        : '$completed of ${dayTasks.length} tasks complete',
                    style: titleTextStle.copyWith(color: Colors.white),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: titleTextStle.copyWith(
                    color: const Color(0xFF8FB2FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white12,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF7EA5FF)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _summaryMetric('Open', open, orangeClr),
                const SizedBox(width: 10),
                _summaryMetric('Done', completed, greenClr),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nextTask == null
                        ? 'No pending tasks'
                        : 'Next: ${nextTask.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: body2TextStyle.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryMetric(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: Get.isDarkMode ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: bodyTextStyle.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget searchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            style: bodyTextStyle,
            decoration: InputDecoration(
              filled: true,
              fillColor: Get.isDarkMode ? darkHeaderClr : Colors.white,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchTerm.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: searchController.clear,
                    ),
              hintText: 'Search tasks',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Get.isDarkMode ? Colors.white12 : lightBorderClr,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _filterChip('All', _TaskView.all),
              const SizedBox(width: 8),
              _filterChip('Open', _TaskView.open),
              const SizedBox(width: 8),
              _filterChip('Done', _TaskView.done),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh tasks',
                onPressed: taskController.getTasks,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, _TaskView view) {
    final isSelected = selectedView == view;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          selectedView = view;
        });
      },
      selectedColor: primaryClr,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : Get.isDarkMode
                ? Colors.white70
                : Colors.black87,
      ),
      backgroundColor: Get.isDarkMode ? darkHeaderClr : Colors.white,
      side: BorderSide(
        color: isSelected
            ? primaryClr
            : Get.isDarkMode
                ? Colors.white12
                : lightBorderClr,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      showCheckmark: false,
    );
  }

  Widget dateBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Get.isDarkMode ? Colors.white12 : lightBorderClr,
        ),
      ),
      child: DatePicker(
        DateTime.now().subtract(const Duration(days: 2)),
        height: 92,
        initialSelectedDate: selectedDate,
        daysCount: 45,
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 11.0,
            color: Colors.grey,
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 11.0,
            color: Colors.grey,
          ),
        ),
        onDateChange: (date) {
          setState(() {
            selectedDate = date;
          });
          taskController.getTasks();
        },
      ),
    );
  }

  Widget showTasks() {
    return Expanded(
      child: Obx(() {
        final visibleTasks = filteredTasks(taskController.taskList);

        if (visibleTasks.isEmpty) {
          return noTaskMsg();
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 92),
            itemCount: visibleTasks.length,
            itemBuilder: (context, index) {
              final task = visibleTasks[index];

              return Dismissible(
                key: ValueKey('${task.id}-${task.title}'),
                background: swipeBackground(
                  color: Colors.redAccent,
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  alignment: Alignment.centerLeft,
                ),
                secondaryBackground: swipeBackground(
                  color: task.isCompleted == 1 ? orangeClr : greenClr,
                  icon: task.isCompleted == 1
                      ? Icons.undo
                      : Icons.check_circle_outline,
                  label: task.isCompleted == 1 ? 'Reopen' : 'Done',
                  alignment: Alignment.centerRight,
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    taskController.deleteTask(task);
                    Get.snackbar(
                      'Task Deleted',
                      '${task.title} has been deleted.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return true;
                  }

                  taskController.setTaskCompletion(
                    task.id!,
                    task.isCompleted == 0,
                  );
                  return false;
                },
                child: AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 320),
                  child: SlideAnimation(
                    verticalOffset: 24,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TaskTile(
                          task,
                          onTap: () => showTaskActions(context, task),
                          onToggle: () => taskController.setTaskCompletion(
                            task.id!,
                            task.isCompleted == 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget swipeBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    final isRight = alignment == Alignment.centerRight;
    return Container(
      alignment: alignment,
      padding: EdgeInsets.only(left: isRight ? 0 : 24, right: isRight ? 24 : 0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment:
            isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  List<Task> filteredTasks(List<Task> tasks) {
    return tasksForDate(tasks).where((task) {
      final matchesSearch = searchTerm.isEmpty ||
          task.title.toLowerCase().contains(searchTerm) ||
          task.note.toLowerCase().contains(searchTerm);
      final matchesView = selectedView == _TaskView.all ||
          (selectedView == _TaskView.open && task.isCompleted == 0) ||
          (selectedView == _TaskView.done && task.isCompleted == 1);
      return matchesSearch && matchesView;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Task> tasksForDate(List<Task> tasks) {
    return tasks.where((task) {
      final taskDate = DateFormat.yMd().parse(task.date);

      if (isSameDay(taskDate, selectedDate)) {
        return true;
      }
      if (task.repeat == 'Daily') {
        return !selectedDate.isBefore(taskDate);
      }
      if (task.repeat == 'Weekly') {
        return !selectedDate.isBefore(taskDate) &&
            taskDate.weekday == selectedDate.weekday;
      }
      if (task.repeat == 'Monthly') {
        return !selectedDate.isBefore(taskDate) &&
            taskDate.day == selectedDate.day;
      }
      return false;
    }).toList();
  }

  bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Future<void> openAddTask() async {
    await Get.to(() => const AddTaskPage());
    taskController.getTasks();
  }

  void showTaskActions(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? darkHeaderClr : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 48,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(task.title, style: titleTextStle),
                subtitle: Text(
                  '${task.startTime} - ${task.endTime}',
                  style: subTitleTextStle,
                ),
                trailing: Icon(
                  task.isCompleted == 1
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.isCompleted == 1 ? greenClr : primaryClr,
                ),
              ),
              buildBottomSheetButton(
                label: task.isCompleted == 1 ? 'Reopen Task' : 'Mark Complete',
                icon: task.isCompleted == 1
                    ? Icons.undo
                    : Icons.check_circle_outline,
                onTap: () {
                  taskController.setTaskCompletion(
                    task.id!,
                    task.isCompleted == 0,
                  );
                  Get.back();
                },
                clr: task.isCompleted == 1 ? orangeClr : greenClr,
              ),
              buildBottomSheetButton(
                label: 'Edit Task',
                icon: Icons.edit_outlined,
                onTap: () async {
                  Get.back();
                  await Get.to(() => AddTaskPage(task: task));
                  taskController.getTasks();
                },
                clr: primaryClr,
              ),
              buildBottomSheetButton(
                label: 'Duplicate',
                icon: Icons.copy,
                onTap: () {
                  taskController.duplicateTask(task);
                  Get.back();
                },
                clr: purpleClr,
              ),
              buildBottomSheetButton(
                label: 'Move To Tomorrow',
                icon: Icons.event_repeat,
                onTap: () {
                  final tomorrow = selectedDate.add(const Duration(days: 1));
                  taskController.updateTask(
                    task.copyWith(date: DateFormat.yMd().format(tomorrow)),
                  );
                  Get.back();
                },
                clr: pinkClr,
              ),
              buildBottomSheetButton(
                label: 'Delete Task',
                icon: Icons.delete_outline,
                onTap: () {
                  taskController.deleteTask(task);
                  Get.back();
                },
                clr: Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget buildBottomSheetButton({
    required String label,
    required IconData icon,
    required Function onTap,
    required Color clr,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onTap as void Function()?,
          style: ElevatedButton.styleFrom(
            backgroundColor: clr,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }

  Widget noTaskMsg() {
    final hasSearch = searchTerm.isNotEmpty || selectedView != _TaskView.all;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'images/task.svg',
          color: primaryClr.withValues(alpha: 0.5),
          height: 96,
          semanticsLabel: 'Task',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
          child: Text(
            hasSearch
                ? 'No tasks match this view.'
                : 'No tasks planned for this day yet.',
            textAlign: TextAlign.center,
            style: subTitleTextStle,
          ),
        ),
        const SizedBox(height: 84),
      ],
    );
  }
}
