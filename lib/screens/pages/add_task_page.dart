import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/controllers/task_controller.dart';
import 'package:task_manager_app/models/task_model.dart';
import 'package:task_manager_app/screens/theme.dart';
import 'package:task_manager_app/screens/widgets/custom_button.dart';
import 'package:task_manager_app/screens/widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  final Task? task;

  const AddTaskPage({Key? key, this.task}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController taskController = Get.find<TaskController>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String startTime = "8:30 AM";
  String endTime = "9:30 AM";
  int selectedColor = 0;
  int selectedRemind = 5;
  String selectedRepeat = 'None';

  List<int> remindList = [5, 10, 15, 20, 30, 60];
  List<String> repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();

    final now = TimeOfDay.now();
    final oneHourLater = now.replacing(
      hour: (now.hour + 1) % 24,
      minute: now.minute,
    );
    final twoHoursLater = now.replacing(
      hour: (now.hour + 2) % 24,
      minute: now.minute,
    );

    startTime = oneHourLater.toString();
    endTime = twoHoursLater.toString();

    if (widget.task != null) {
      titleController.text = widget.task!.title;
      noteController.text = widget.task!.note;
      selectedDate = DateFormat.yMd().parse(widget.task!.date);
      startTime = widget.task!.startTime;
      endTime = widget.task!.endTime;
      selectedRemind = widget.task!.remind;
      selectedRepeat = widget.task!.repeat;
      selectedColor = widget.task!.color;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.task != null) {
      return;
    }

    final now = TimeOfDay.now();
    final oneHourLater = now.replacing(
      hour: (now.hour + 1) % 24,
      minute: now.minute,
    );
    final twoHoursLater = now.replacing(
      hour: (now.hour + 2) % 24,
      minute: now.minute,
    );

    startTime = oneHourLater.format(context);
    endTime = twoHoursLater.format(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: appBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task == null ? 'Create a task' : 'Update your task',
                  style: headingTextStyle.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 5),
                Text(
                  DateFormat('EEEE, MMMM d').format(selectedDate),
                  style: body2TextStyle,
                ),
                const SizedBox(height: 24),
                sectionLabel('Task details'),
                InputField(
                  title: "Title",
                  hint: "What needs to be done?",
                  controller: titleController,
                  icon: Icons.check_circle_outline_rounded,
                ),
                InputField(
                  title: "Note",
                  hint: "Add useful details",
                  controller: noteController,
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                sectionLabel('Schedule'),
                InputField(
                  title: "Date",
                  hint: DateFormat('EEE, MMM d, y').format(selectedDate),
                  icon: Icons.calendar_today_outlined,
                  onTap: getDateFromUser,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InputField(
                        title: "Start Time",
                        hint: startTime,
                        icon: Icons.schedule_rounded,
                        onTap: () => getTimeFromUser(isStartTime: true),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: InputField(
                        title: "End Time",
                        hint: endTime,
                        icon: Icons.schedule_rounded,
                        onTap: () => getTimeFromUser(isStartTime: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                sectionLabel('Preferences'),
                InputField(
                  title: "Remind",
                  hint: "$selectedRemind minutes early",
                  icon: Icons.notifications_none_rounded,
                  widget: remindDropDown(),
                ),
                InputField(
                  title: "Repeat",
                  hint: selectedRepeat,
                  icon: Icons.repeat_rounded,
                  widget: repeatDropDown(),
                ),
                const SizedBox(height: 20),
                colorChips(),
                const SizedBox(height: 28),
                CustomButton(
                  width: double.infinity,
                  icon: widget.task == null
                      ? Icons.add_task_rounded
                      : Icons.save_outlined,
                  label: widget.task == null ? "Create task" : "Save changes",
                  onTap: validateInputs,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: primaryClr,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          label.toUpperCase(),
          style: bodyTextStyle.copyWith(
            color: primaryClr,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  validateInputs() {
    if (titleController.text.trim().isNotEmpty) {
      addOrUpdateTask();
      Get.back();
    } else {
      Get.snackbar(
        "Required",
        "Please enter a task title before proceeding.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: EdgeInsets.all(20),
        borderRadius: 10,
        duration: Duration(seconds: 3),
      );
    }
  }

  addOrUpdateTask() async {
    if (widget.task == null) {
      await taskController.addTask(
        Task(
          note: noteController.text.trim(),
          title: titleController.text.trim(),
          date: DateFormat.yMd().format(selectedDate),
          startTime: startTime,
          endTime: endTime,
          remind: selectedRemind,
          repeat: selectedRepeat,
          color: selectedColor,
          isCompleted: 0,
        ),
      );
    } else {
      taskController.updateTask(
        Task(
          id: widget.task!.id,
          note: noteController.text.trim(),
          title: titleController.text.trim(),
          date: DateFormat.yMd().format(selectedDate),
          startTime: startTime,
          endTime: endTime,
          remind: selectedRemind,
          repeat: selectedRepeat,
          color: selectedColor,
          isCompleted: widget.task!.isCompleted,
        ),
      );
    }
  }

  Widget remindDropDown() {
    return DropdownButton<String>(
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      iconSize: 24,
      elevation: 4,
      style: GoogleFonts.lato(textStyle: subTitleTextStle),
      underline: Container(height: 0),
      onChanged: (String? newValue) {
        setState(() {
          selectedRemind = int.parse(newValue!);
        });
      },
      items: remindList.map<DropdownMenuItem<String>>((int value) {
        return DropdownMenuItem<String>(
          value: value.toString(),
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }

  Widget repeatDropDown() {
    return DropdownButton<String>(
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      iconSize: 24,
      elevation: 4,
      style: GoogleFonts.lato(textStyle: subTitleTextStle),
      underline: Container(height: 0),
      onChanged: (String? newValue) {
        setState(() {
          selectedRepeat = newValue!;
        });
      },
      items: repeatList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  colorChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Accent color",
          style: bodyTextStyle.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          children: List<Widget>.generate(3, (int index) {
            final colors = [purpleClr, pinkClr, yellowClr];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: index == selectedColor
                          ? context.theme.colorScheme.onSurface
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: index == selectedColor
                      ? const Icon(Icons.done_rounded,
                          color: Colors.white, size: 18)
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      toolbarHeight: 68,
      leading: IconButton(
        tooltip: 'Back',
        onPressed: Get.back,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text(
        widget.task == null ? 'New Task' : 'Edit Task',
        style: titleTextStle,
      ),
      centerTitle: false,
    );
  }

  getTimeFromUser({required bool isStartTime}) async {
    var pickedTime = await _showTimePicker();
    if (pickedTime != null) {
      String formattedTime = pickedTime.format(context);
      setState(() {
        if (isStartTime) {
          startTime = formattedTime;
        } else {
          endTime = formattedTime;
        }
      });
    }
  }

  _showTimePicker() {
    final currentTime = TimeOfDay.now();
    final oneHourLater = currentTime.replacing(
      hour: (currentTime.hour + 1) % 24,
      minute: currentTime.minute,
    );

    return showTimePicker(
      initialTime: oneHourLater,
      context: context,
    );
  }

  getDateFromUser() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(), // Prevents selecting past dates
      lastDate: DateTime(2101),
    );
    if (pickedDate != null &&
        pickedDate.isAfter(DateTime.now().subtract(Duration(days: 1)))) {
      setState(() {
        selectedDate = pickedDate;
      });
    } else {
      Get.snackbar(
        "Invalid Date",
        "Please select a date today or in the future.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: EdgeInsets.all(20),
        borderRadius: 10,
        duration: Duration(seconds: 3),
      );
    }
  }
}
