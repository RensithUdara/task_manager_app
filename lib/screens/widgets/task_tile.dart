import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_manager_app/models/task_model.dart';
import 'package:task_manager_app/screens/size_config.dart';
import 'package:task_manager_app/screens/theme.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  TaskTile(this.task);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
      width: SizeConfig.screenWidth,
      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _getBGClr(task.color),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alarm,
                      color: Colors.grey[200],
                      size: 15,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "${task.startTime} - ${task.endTime}",
                      style: GoogleFonts.lato(
                        textStyle:
                            TextStyle(fontSize: 13, color: Colors.grey[100]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  task.note,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(fontSize: 12, color: Colors.grey[100]),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            width: 0.5,
            color: Colors.grey[200]!.withOpacity(0.7),
          ),
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              task.isCompleted == 1 ? "COMPLETED" : "TODO",
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  _getBGClr(int no) {
    switch (no) {
      case 0:
        return purpleClr;
      case 1:
        return pinkClr;
      case 2:
        return yellowClr;
      default:
        return purpleClr;
    }
  }
}
