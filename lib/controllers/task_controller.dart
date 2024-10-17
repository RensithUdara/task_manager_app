import 'package:get/get.dart';
import 'package:task_management/db/db_helper.dart';
import 'package:task_management/models/task_model.dart';

class TaskController extends GetxController {
  final RxList<Task> taskList = RxList<Task>();

  @override
  void onReady() {
    getTasks();
    super.onReady();
  }

  // Add task to the table
  Future<int> addTask(Task task) async {
    return await DBHelper.insert(task);
  }

  // Fetch all the data from the table
  void getTasks() async {
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

  // Delete task from the table
  void deleteTask(Task task) async {
    await DBHelper.delete(task);
    getTasks();
  }

  // Mark a task as completed in the table
  void markTaskCompleted(int id) async {
    await DBHelper.update(id);
    getTasks();
  }

  // Update an existing task in the table
  void updateTask(Task task) async {
    await DBHelper.updateTask(task);
    getTasks();
  }
}
