import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskPriority {
  @HiveField(0)
  mustDo,
  @HiveField(1)
  couldDo,
}

@HiveType(typeId: 1)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final TaskPriority priority;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? description;

  Task({
    String? id,
    required this.title,
    required this.priority,
    this.isCompleted = false,
    DateTime? createdAt,
    this.description,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
  Task copyWith({
    String? title,
    TaskPriority? priority,
    bool? isCompleted,
    String? description,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.name,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.couldDo,
      ),
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      description: json['description'],
    );
  }
}
