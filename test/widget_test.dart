import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_app/models/task_model.dart';

void main() {
  group('Task', () {
    test('loads defaults from databases created before reminder features', () {
      final task = Task.fromJson({
        'id': 4,
        'title': 'Review release',
        'note': '',
        'isCompleted': 0,
        'date': '9/27/2026',
        'startTime': '9:00 AM',
        'endTime': '10:00 AM',
        'color': 0,
        'remind': 10,
        'repeat': 'None',
      });

      expect(task.priority, 'Medium');
      expect(task.reminderEnabled, isTrue);
    });

    test('serializes priority and reminder preference for SQLite', () {
      final task = Task(
        title: 'Plan sprint',
        note: 'Prepare backlog',
        isCompleted: 0,
        date: '9/28/2026',
        startTime: '8:30 AM',
        endTime: '9:30 AM',
        color: 1,
        remind: 30,
        repeat: 'Weekly',
        priority: 'High',
        reminderEnabled: false,
      );

      expect(task.toJson()['priority'], 'High');
      expect(task.toJson()['reminderEnabled'], 0);
    });

    test('copyWith can clear an id when duplicating a task', () {
      final task = Task(
        id: 9,
        title: 'Prepare report',
        note: '',
        isCompleted: 0,
        date: '9/28/2026',
        startTime: '8:30 AM',
        endTime: '9:30 AM',
        color: 0,
        remind: 5,
        repeat: 'None',
      );

      expect(task.copyWith(id: null).id, isNull);
    });
  });
}
