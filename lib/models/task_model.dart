class Task {
  static const Object _unset = Object();

  int? id;
  String title;
  String note;
  int isCompleted;
  String date;
  String startTime;
  String endTime;
  int color;
  int remind;
  String repeat;
  String priority;
  bool reminderEnabled;

  Task({
    this.id,
    required this.title,
    required this.note,
    required this.isCompleted,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.remind,
    required this.repeat,
    this.priority = 'Medium',
    this.reminderEnabled = true,
  });

  Task.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        title = json['title'],
        note = json['note'],
        isCompleted = json['isCompleted'],
        date = json['date'],
        startTime = json['startTime'],
        endTime = json['endTime'],
        color = json['color'],
        remind = json['remind'],
        repeat = json['repeat'],
        priority = (json['priority'] as String?) ?? 'Medium',
        reminderEnabled = (json['reminderEnabled'] as int? ?? 1) == 1;

  Task copyWith({
    Object? id = _unset,
    String? title,
    String? note,
    int? isCompleted,
    String? date,
    String? startTime,
    String? endTime,
    int? color,
    int? remind,
    String? repeat,
    String? priority,
    bool? reminderEnabled,
  }) {
    return Task(
      id: identical(id, _unset) ? this.id : id as int?,
      title: title ?? this.title,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      remind: remind ?? this.remind,
      repeat: repeat ?? this.repeat,
      priority: priority ?? this.priority,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['note'] = note;
    data['isCompleted'] = isCompleted;
    data['date'] = date;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['color'] = color;
    data['remind'] = remind;
    data['repeat'] = repeat;
    data['priority'] = priority;
    data['reminderEnabled'] = reminderEnabled ? 1 : 0;
    return data;
  }
}
