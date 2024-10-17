import 'dart:async';

import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:task_management/controllers/task_controller.dart';
import 'package:task_management/models/task_model.dart';
import 'package:task_management/screens/pages/add_task_page.dart';
import 'package:task_management/screens/size_config.dart';
import 'package:task_management/screens/theme.dart';
import 'package:task_management/screens/widgets/custom_button.dart';
import 'package:task_management/screens/widgets/task_tile.dart';
import 'package:task_management/services/notification_services.dart';
import 'package:task_management/services/theme_services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.parse(DateTime.now().toString());
  final taskController = Get.put(TaskController());
  var notifyHelper;
  Timer? autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();

    autoRefreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      taskController.getTasks(); 
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: appBar(),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          addTaskBar(),
          dateBar(),
          SizedBox(height: 12),
          showTasks(),
        ],
      ),
    );
  }

  dateBar() {
    return Container(
      padding: EdgeInsets.only(bottom: 4),
      child: DatePicker(
        DateTime.now(),
        initialSelectedDate: DateTime.now(),
        selectionColor: context.theme.scaffoldBackgroundColor,
        selectedTextColor: primaryClr,
        dateTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 10.0,
            color: Colors.grey,
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 10.0,
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

  addTaskBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingTextStyle,
              ),
              Text("Today", style: headingTextStyle),
            ],
          ),
          CustomButton(
            label: "+ Add Task",
            onTap: () async {
              await Get.to(AddTaskPage());
              taskController.getTasks();
            },
          ),
        ],
      ),
    );
  }

  appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      title: Text(
        'Task Management App',
        style: headingTextStyle.copyWith(
          color: Color.fromARGB(255, 160, 51, 138),
        ),
      ),
      leading: GestureDetector(
        onTap: () {
          ThemeService().switchTheme();
          notifyHelper.displayNotification(
            title: "Theme Changed",
            body: Get.isDarkMode
                ? "Light theme activated."
                : "Dark theme activated",
          );
        },
        child: Icon(
          Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: Get.isDarkMode ? Colors.white : darkGreyClr,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage("images/logo.jpg"),
          ),
        ),
        SizedBox(width: 12),
      ],
    );
  }

  showTasks() {
    return Expanded(
      child: Obx(() {
        var tasksForSelectedDate = taskController.taskList.where((task) {
          DateTime taskDate = DateFormat.yMd().parse(task.date);

          if (taskDate.isAtSameMomentAs(selectedDate)) {
            return true;
          }
          if (task.repeat == 'Daily') {
            return true;
          } else if (task.repeat == 'Weekly') {
            return taskDate.weekday == selectedDate.weekday;
          } else if (task.repeat == 'Monthly') {
            return taskDate.day == selectedDate.day;
          }
          return false;
        }).toList();

        if (tasksForSelectedDate.isEmpty) {
          return noTaskMsg();
        } else {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: tasksForSelectedDate.length,
            itemBuilder: (context, index) {
              Task task = tasksForSelectedDate[index];

              return Dismissible(
                key: Key(task.id.toString()),
                background: swipeBackgroundDelete(),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                  taskController.deleteTask(task);
                  setState(() {
                    tasksForSelectedDate.removeAt(index);
                  });
                  Get.snackbar(
                    "Task Deleted",
                    "${task.title} has been deleted.",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () {
                          showBottomSheet(context, task);
                        },
                        child: TaskTile(task),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }

  Widget swipeBackgroundDelete() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 20.0),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        height: task.isCompleted == 1
            ? SizeConfig.screenHeight! * 0.25
            : SizeConfig.screenHeight! * 0.30,
        width: SizeConfig.screenWidth,
        decoration: BoxDecoration(
          color: Get.isDarkMode ? darkHeaderClr : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 50,
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                ),
              ),
              task.isCompleted == 1
                  ? Container()
                  : buildBottomSheetButton(
                      label: "Mark as Completed",
                      icon: Icons.check_circle_outline,
                      onTap: () {
                        Get.back();
                        taskController.markTaskCompleted(task.id!);
                      },
                      clr: Colors.green,
                    ),
              buildBottomSheetButton(
                label: "Edit Task",
                icon: Icons.edit,
                onTap: () async {
                  await Get.to(AddTaskPage(task: task));
                  taskController.getTasks();
                  Get.back();
                },
                clr: Colors.blue,
              ),
              buildBottomSheetButton(
                label: "Delete Task",
                icon: Icons.delete_outline,
                onTap: () {
                  taskController.deleteTask(task);
                  Get.back();
                },
                clr: Colors.red,
              ),
              buildBottomSheetButton(
                label: "Close",
                icon: Icons.close,
                onTap: () {
                  Get.back();
                },
                isClose: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildBottomSheetButton({
    required String label,
    required IconData icon,
    required Function onTap,
    Color? clr,
    bool? isClose,
  }) {
    isClose ??= false;
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        height: 45,
        width: SizeConfig.screenWidth! * 0.85,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: isClose
                ? Get.isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[300]!
                : clr ?? Colors.white,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isClose ? Colors.grey : Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: isClose
                  ? titleTextStle.copyWith(color: Colors.grey)
                  : titleTextStle.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  noTaskMsg() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "images/task.svg",
          color: primaryClr.withOpacity(0.5),
          height: 90,
          semanticsLabel: 'Task',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Text(
            "You do not have any tasks yet!\nAdd new tasks to make your days productive.",
            textAlign: TextAlign.center,
            style: subTitleTextStle,
          ),
        ),
        SizedBox(height: 80),
      ],
    );
  }
}
