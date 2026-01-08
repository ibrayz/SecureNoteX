class Task {
  int? id;
  String title;
  String description;
  int priority; // 1: Düşük, 2: Orta, 3: Yüksek
  bool isCompleted;
  DateTime? dueDate;
  int pomodoroCount;
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.priority = 2,
    this.isCompleted = false,
    this.dueDate,
    this.pomodoroCount = 0,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'dueDate': dueDate?.toIso8601String(),
      'pomodoroCount': pomodoroCount,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      priority: map['priority'] as int,
      isCompleted: (map['isCompleted'] as int) == 1,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      pomodoroCount: map['pomodoroCount'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
    );
  }

  String get priorityText {
    switch (priority) {
      case 1:
        return 'Düşük';
      case 3:
        return 'Yüksek';
      default:
        return 'Orta';
    }
  }
}