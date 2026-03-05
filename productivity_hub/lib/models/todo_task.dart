enum TaskPriority { low, medium, high }

class TodoTask {
  TodoTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.dueDate,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime? dueDate;

  bool get isOverdue {
    if (dueDate == null || isCompleted) {
      return false;
    }
    return dueDate!.isBefore(DateTime.now());
  }

  TodoTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return TodoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory TodoTask.fromMap(Map<String, dynamic> map) {
    final priorityName =
        (map['priority'] as String?) ?? TaskPriority.medium.name;
    return TodoTask(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      priority: TaskPriority.values.firstWhere(
        (value) => value.name == priorityName,
        orElse: () => TaskPriority.medium,
      ),
      dueDate: DateTime.tryParse((map['dueDate'] as String?) ?? ''),
    );
  }
}
