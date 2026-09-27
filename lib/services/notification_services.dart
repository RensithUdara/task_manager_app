import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/models/task_model.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String channelId = 'task_reminders';
  static const int testNotificationId = 1000000;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final ValueNotifier<int?> selectedTaskId = ValueNotifier<int?>(null);

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }

    tz_data.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (error) {
      debugPrint('Unable to configure the local timezone: $error');
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _setSelectedTask(launchDetails?.notificationResponse?.payload);
    }
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      return false;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    final macosGranted = await macos?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return androidGranted ?? iosGranted ?? macosGranted ?? true;
  }

  Future<bool> notificationsEnabled() async {
    if (kIsWeb) {
      return false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? true;
  }

  Future<int> pendingCount() async {
    if (kIsWeb) {
      return 0;
    }
    return (await _plugin.pendingNotificationRequests()).length;
  }

  Future<bool> scheduleTask(
    Task task, {
    bool requestPermission = false,
  }) async {
    if (!_initialized || task.id == null) {
      return false;
    }

    await cancelTask(task.id!);
    if (task.isCompleted == 1 || !task.reminderEnabled) {
      return false;
    }

    if (requestPermission && !await requestPermissions()) {
      return false;
    }

    final schedule = _scheduleFor(task);
    if (schedule == null) {
      return false;
    }

    await _plugin.zonedSchedule(
      task.id!,
      task.title,
      _notificationBody(task),
      schedule.date,
      _notificationDetails,
      payload: 'task:${task.id}',
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: schedule.components,
    );
    return true;
  }

  Future<void> syncTasks(Iterable<Task> tasks) async {
    if (!_initialized) {
      return;
    }
    await _plugin.cancelAll();
    for (final task in tasks) {
      await scheduleTask(task);
    }
  }

  Future<void> cancelTask(int id) async {
    if (_initialized) {
      await _plugin.cancel(id);
    }
  }

  Future<void> showTestNotification() async {
    if (!await requestPermissions()) {
      return;
    }
    await _plugin.show(
      testNotificationId,
      'TaskFlow reminders are ready',
      'You will be notified before your scheduled tasks.',
      _notificationDetails,
      payload: 'test',
    );
  }

  Future<void> displayNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      return;
    }
    await _plugin.show(
      testNotificationId,
      title,
      body,
      _notificationDetails,
    );
  }

  void clearSelectedTask() {
    selectedTaskId.value = null;
  }

  void _handleNotificationResponse(NotificationResponse response) {
    _setSelectedTask(response.payload);
  }

  void _setSelectedTask(String? payload) {
    if (payload == null || !payload.startsWith('task:')) {
      return;
    }
    selectedTaskId.value = int.tryParse(payload.substring(5));
  }

  _TaskSchedule? _scheduleFor(Task task) {
    final date = DateFormat.yMd().parse(task.date);
    final time = DateFormat.jm().parse(task.startTime);
    var scheduled = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).subtract(Duration(minutes: task.remind));

    final now = tz.TZDateTime.now(tz.local);
    DateTimeComponents? components;
    switch (task.repeat) {
      case 'Daily':
        components = DateTimeComponents.time;
        while (!scheduled.isAfter(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }
      case 'Weekly':
        components = DateTimeComponents.dayOfWeekAndTime;
        while (!scheduled.isAfter(now)) {
          scheduled = scheduled.add(const Duration(days: 7));
        }
      case 'Monthly':
        components = DateTimeComponents.dayOfMonthAndTime;
        while (!scheduled.isAfter(now)) {
          scheduled = _nextValidMonth(scheduled);
        }
      default:
        if (!scheduled.isAfter(now)) {
          return null;
        }
    }

    return _TaskSchedule(scheduled, components);
  }

  tz.TZDateTime _nextValidMonth(tz.TZDateTime date) {
    var year = date.year;
    var month = date.month + 1;
    while (true) {
      if (month > 12) {
        month = 1;
        year++;
      }
      final lastDay = tz.TZDateTime(tz.local, year, month + 1, 0).day;
      if (date.day <= lastDay) {
        return tz.TZDateTime(
          tz.local,
          year,
          month,
          math.min(date.day, lastDay),
          date.hour,
          date.minute,
        );
      }
      month++;
    }
  }

  String _notificationBody(Task task) {
    final note = task.note.trim();
    final prefix = '${task.priority} priority • Starts at ${task.startTime}';
    return note.isEmpty ? prefix : '$prefix\n$note';
  }

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      'Task reminders',
      channelDescription: 'Reminders for upcoming TaskFlow tasks',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
    macOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );
}

class _TaskSchedule {
  const _TaskSchedule(this.date, this.components);

  final tz.TZDateTime date;
  final DateTimeComponents? components;
}
