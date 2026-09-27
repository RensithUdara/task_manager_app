import 'package:get/get.dart';
import 'package:task_manager_app/db/db_helper.dart';
import 'package:task_manager_app/models/task_model.dart';
import 'package:task_manager_app/services/notification_services.dart';

class TaskController extends GetxController {
  final RxList<Task> taskList = RxList<Task>();

  @override
  Future<void> onReady() async {
    super.onReady();
    await getTasks();
    await NotificationService.instance.syncTasks(taskList);
  }

  // Add task to the table
  Future<int> addTask(Task task) async {
    final id = await DBHelper.insert(task);
    await NotificationService.instance.scheduleTask(
      task.copyWith(id: id),
      requestPermission: task.reminderEnabled,
    );
    await getTasks();
    return id;
  }

  // Fetch all the data from the table
  Future<void> getTasks() async {
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

  // Delete task from the table
  Future<void> deleteTask(Task task) async {
    if (task.id != null) {
      await NotificationService.instance.cancelTask(task.id!);
    }
    await DBHelper.delete(task);
    await getTasks();
  }

  // Mark a task as completed in the table
  Future<void> markTaskCompleted(int id) async {
    await setTaskCompletion(id, true);
  }

  Future<void> setTaskCompletion(int id, bool isCompleted) async {
    await DBHelper.updateCompletion(id, isCompleted ? 1 : 0);
    await getTasks();
    final task = _findTask(id);
    if (isCompleted || task == null) {
      await NotificationService.instance.cancelTask(id);
    } else {
      await NotificationService.instance.scheduleTask(task);
    }
  }

  // Update an existing task in the table
  Future<void> updateTask(Task task) async {
    await DBHelper.updateTask(task);
    if (task.id != null) {
      await NotificationService.instance.scheduleTask(
        task,
        requestPermission: task.reminderEnabled,
      );
    }
    await getTasks();
  }

  Future<int> duplicateTask(Task task) async {
    final duplicatedTask = task.copyWith(
      id: null,
      title: '${task.title} Copy',
      isCompleted: 0,
    );
    return addTask(duplicatedTask);
  }

  Task? _findTask(int id) {
    for (final task in taskList) {
      if (task.id == id) {
        return task;
      }
    }
    return null;
  }
}
