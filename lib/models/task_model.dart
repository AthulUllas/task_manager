class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final int priority;
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
    int? priority,
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
    return TaskModel(
      id: taskId ?? json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      category: json['category'] as String? ?? 'General',
      dueDate: _parseDate(json['due_date']),
      isCompleted: json['is_completed'] as bool? ?? false,
      createdDate: _parseDate(json['created_date'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'priority': priority,
      'category': category,
      'due_date': dueDate.toIso8601String(),
      'is_completed': isCompleted,
      'created_date': createdDate.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic dateData) {
    if (dateData == null) return DateTime.now();
    if (dateData is String) {
      return DateTime.tryParse(dateData) ?? DateTime.now();
    }
    try {
      return (dateData as dynamic).toDate(); // For Firestore timestamps if needed
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, userId: $userId, title: $title, priority: $priority, category: $category, isCompleted: $isCompleted)';
  }
}
