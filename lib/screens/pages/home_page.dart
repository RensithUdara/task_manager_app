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
import 'package:task_manager_app/screens/widgets/custom_button.dart';
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
  final NotificationService notificationService = NotificationService.instance;

  DateTime selectedDate = DateTime.now();
  Timer? autoRefreshTimer;
  _TaskView selectedView = _TaskView.all;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    notificationService.selectedTaskId.addListener(_openSelectedTask);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openSelectedTask());
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
    notificationService.selectedTaskId.removeListener(_openSelectedTask);
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
        backgroundColor: primaryClr,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Task'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            addTaskBar(),
            summaryPanel(),
            searchAndFilters(),
            dateBar(),
            const SizedBox(height: 8),
            showTasks(),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      titleSpacing: 0,
      leading: IconButton(
        tooltip: 'Switch theme',
        onPressed: () {
          ThemeService().switchTheme();
        },
        icon: Icon(
          Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: Get.isDarkMode ? Colors.white : darkGreyClr,
        ),
      ),
      title: Text(
        'TaskFlow',
        style: headingTextStyle.copyWith(color: primaryClr),
      ),
      actions: [
        IconButton(
          tooltip: 'Notification center',
          onPressed: showNotificationCenter,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 22,
            backgroundImage: const AssetImage('images/logo.jpg'),
          ),
        ),
      ],
    );
  }

  Widget addTaskBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.EEEE().format(DateTime.now()),
                  style: subTitleTextStle,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: headingTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          CustomButton(
            label: '+ Add',
            onTap: openAddTask,
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? darkHeaderClr : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: Get.isDarkMode ? 0.2 : 0.06,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
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
                    style: titleTextStle,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: titleTextStle.copyWith(color: primaryClr),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    Get.isDarkMode ? Colors.white12 : Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(primaryClr),
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
                    style: body2TextStyle,
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
          Text('$value $label', style: bodyTextStyle),
        ],
      ),
    );
  }

  Widget searchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            style: bodyTextStyle,
            decoration: InputDecoration(
              filled: true,
              fillColor: Get.isDarkMode ? darkHeaderClr : Colors.white,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchTerm.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: searchController.clear,
                    ),
              hintText: 'Search tasks and notes',
              hintStyle: subTitleTextStle,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
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
        color: isSelected ? primaryClr : Colors.transparent,
      ),
    );
  }

  Widget dateBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
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
            padding: const EdgeInsets.only(bottom: 92, top: 4),
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
                      child: GestureDetector(
                        onTap: () {
                          showTaskActions(context, task);
                        },
                        child: TaskTile(task),
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
      color: color,
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

  void _openSelectedTask() {
    final taskId = notificationService.selectedTaskId.value;
    if (taskId == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await taskController.getTasks();
      if (!mounted) {
        return;
      }

      Task? selectedTask;
      for (final task in taskController.taskList) {
        if (task.id == taskId) {
          selectedTask = task;
          break;
        }
      }
      notificationService.clearSelectedTask();
      if (selectedTask != null) {
        showTaskActions(context, selectedTask);
      }
    });
  }

  Future<void> showNotificationCenter() async {
    var enabled = await notificationService.notificationsEnabled();
    var pending = await notificationService.pendingCount();
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Get.isDarkMode ? darkHeaderClr : Colors.white,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> refreshStatus() async {
              final nextEnabled =
                  await notificationService.notificationsEnabled();
              final nextPending = await notificationService.pendingCount();
              if (sheetContext.mounted) {
                setSheetState(() {
                  enabled = nextEnabled;
                  pending = nextPending;
                });
              }
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notifications', style: headingTextStyle),
                    const SizedBox(height: 6),
                    Text(
                      enabled
                          ? '$pending task reminders scheduled'
                          : 'Notifications are currently disabled',
                      style: body2TextStyle,
                    ),
                    const SizedBox(height: 18),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: (enabled ? greenClr : orangeClr)
                            .withValues(alpha: 0.14),
                        child: Icon(
                          enabled
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined,
                          color: enabled ? greenClr : orangeClr,
                        ),
                      ),
                      title: Text(
                        enabled ? 'Reminders enabled' : 'Permission needed',
                        style: titleTextStle,
                      ),
                      subtitle: Text(
                        enabled
                            ? 'Task reminders use your device timezone.'
                            : 'Allow notifications to receive task reminders.',
                        style: body2TextStyle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final granted =
                              await notificationService.requestPermissions();
                          if (granted) {
                            await notificationService
                                .syncTasks(taskController.taskList);
                          }
                          await refreshStatus();
                        },
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: Text(
                          enabled ? 'Reschedule reminders' : 'Enable reminders',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await notificationService.showTestNotification();
                          await refreshStatus();
                        },
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('Send test notification'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
        if (!hasSearch)
          TextButton.icon(
            onPressed: openAddTask,
            icon: const Icon(Icons.add),
            label: const Text('Create task'),
          ),
        const SizedBox(height: 84),
      ],
    );
  }
}
