class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String priority;
  final String category;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdDate;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.priority,
    required this.category,
    required this.dueDate,
    this.isCompleted = false,
    required this.createdDate,
  });

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? priority,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json, {String? taskId}) {
    final id =
        taskId ??
        json['id']?.toString() ??
        json['_id']?.toString() ??
        json['task_id']?.toString() ??
        '';

    final rawIsCompleted =
        json['is_completed'] ?? json['completed'] ?? json['isCompleted'];
    bool isCompleted = false;
    if (rawIsCompleted is bool) {
      isCompleted = rawIsCompleted;
    } else if (rawIsCompleted is int) {
      isCompleted = rawIsCompleted == 1;
    } else if (rawIsCompleted is String) {
      isCompleted =
          rawIsCompleted.toLowerCase() == 'true' || rawIsCompleted == '1';
    }

    return TaskModel(
      id: id,
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Medium',
      category: json['category'] as String? ?? 'Personal',
      dueDate: _parseDate(json['due_date'] ?? json['dueDate']),
      isCompleted: isCompleted,
      createdDate: _parseDate(
        json['created_date'] ?? json['createdAt'] ?? json['created_at'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'category': category,
    };
  }

  static DateTime _parseDate(dynamic dateData) {
    if (dateData == null) return DateTime.now();
    if (dateData is String) {
      return DateTime.tryParse(dateData) ?? DateTime.now();
    }
    try {
      return (dateData as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, userId: $userId, title: $title, priority: $priority, category: $category, isCompleted: $isCompleted)';
  }
}
