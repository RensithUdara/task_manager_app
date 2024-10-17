import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:intl/intl.dart';
import 'package:task_management/controllers/task_controller.dart';
import 'package:task_management/models/task_model.dart';
import 'package:task_management/screens/theme.dart';
import 'package:task_management/screens/widgets/custom_button.dart';
import 'package:task_management/screens/widgets/input_field.dart';

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

  List<int> remindList = [5, 10, 15, 20];
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: appBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              InputField(
                title: "Title",
                hint: "Enter title here.",
                controller: titleController,
              ),
              InputField(
                title: "Note",
                hint: "Enter note here.",
                controller: noteController,
              ),
              InputField(
                title: "Date",
                hint: DateFormat.yMd().format(selectedDate),
                widget: IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.grey),
                  onPressed: getDateFromUser,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      title: "Start Time",
                      hint: startTime,
                      widget: IconButton(
                        icon: Icon(Icons.access_time, color: Colors.grey),
                        onPressed: () => getTimeFromUser(isStartTime: true),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: InputField(
                      title: "End Time",
                      hint: endTime,
                      widget: IconButton(
                        icon: Icon(Icons.access_time, color: Colors.grey),
                        onPressed: () => getTimeFromUser(isStartTime: false),
                      ),
                    ),
                  ),
                ],
              ),
              InputField(
                title: "Remind",
                hint: "$selectedRemind minutes early",
                widget: remindDropDown(),
              ),
              InputField(
                title: "Repeat",
                hint: selectedRepeat,
                widget: repeatDropDown(),
              ),
              SizedBox(height: 18.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  colorChips(),
                  CustomButton(
                    label: widget.task == null ? "Create Task" : "Update Task",
                    onTap: validateInputs,
                  ),
                ],
              ),
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  validateInputs() {
    if (titleController.text.isNotEmpty && noteController.text.isNotEmpty) {
      addOrUpdateTask();
      Get.back();
    } else {
      Get.snackbar(
        "Required",
        "Please fill all the fields before proceeding.",
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
          note: noteController.text,
          title: titleController.text,
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
          note: noteController.text,
          title: titleController.text,
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
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      iconSize: 32,
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
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      iconSize: 32,
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
        Text("Color", style: GoogleFonts.lato(textStyle: titleTextStle)),
        SizedBox(height: 8),
        Wrap(
          children: List<Widget>.generate(3, (int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: index == 0
                      ? purpleClr
                      : index == 1
                          ? pinkClr
                          : yellowClr,
                  child: index == selectedColor
                      ? Center(
                          child: Icon(Icons.done, color: Colors.white, size: 18),
                        )
                      : Container(),
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
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Icon(Icons.arrow_back_ios, size: 24, color: primaryClr),
      ),
      title: Text(
        widget.task == null ? 'Add Task' : 'Update Task',
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: primaryClr,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage("images/logo.jpg"),
        ),
        SizedBox(width: 20),
      ],
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
