class Goal {
  int? id;
  String title;
  String description;
  String type; // 'daily', 'weekly', 'monthly'
  int targetCount;
  int currentCount;
  List<DateTime> completedDates;
  DateTime createdAt;
  DateTime? lastCompletedAt;

  Goal({
    this.id,
    required this.title,
    this.description = '',
    this.type = 'daily',
    this.targetCount = 1,
    this.currentCount = 0,
    List<DateTime>? completedDates,
    DateTime? createdAt,
    this.lastCompletedAt,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'completedDates': completedDates.map((d) => d.toIso8601String()).join(','),
      'createdAt': createdAt.toIso8601String(),
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    final datesString = map['completedDates'] as String;
    final dates = datesString.isEmpty
        ? <DateTime>[]
        : datesString.split(',').map((s) => DateTime.parse(s)).toList();

    return Goal(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      targetCount: map['targetCount'] as int,
      currentCount: map['currentCount'] as int,
      completedDates: dates,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastCompletedAt: map['lastCompletedAt'] != null
          ? DateTime.parse(map['lastCompletedAt'] as String)
          : null,
    );
  }

  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    final sorted = List<DateTime>.from(completedDates)..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (var date in sorted) {
      final diff = checkDate.difference(date).inDays;
      if (diff <= 1) {
        streak++;
        checkDate = date;
      } else {
        break;
      }
    }

    return streak;
  }

  bool isCompletedToday() {
    if (completedDates.isEmpty) return false;
    final today = DateTime.now();
    return completedDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }
}