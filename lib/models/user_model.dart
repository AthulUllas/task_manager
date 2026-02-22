class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final String themeMode;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.themeMode,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    String? themeMode,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json, {String? documentId}) {
    return UserModel(
      id: documentId ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt: _parseDate(json['createdAt']),
      themeMode: json['themeMode'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'themeMode': themeMode,
    };
  }

  static DateTime _parseDate(dynamic dateData) {
    if (dateData == null) return DateTime.now();
    if (dateData is String) {
      return DateTime.tryParse(dateData) ?? DateTime.now();
    }
    // If using Firestore Timestamp, we can check for toDate() method:
    // if (dateData is Timestamp) return dateData.toDate();
    try {
      return (dateData as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, createdAt: $createdAt, themeMode: $themeMode)';
  }
}
