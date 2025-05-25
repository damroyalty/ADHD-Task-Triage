import 'package:uuid/uuid.dart';

enum TaskPriority { mustDo, couldDo }

class Task {
  final String id;
  final String title;
  final TaskPriority priority;
  bool isCompleted;
  final DateTime createdAt;
  final String? description; // <-- Add this

  Task({
    String? id,
    required this.title,
    required this.priority,
    this.isCompleted = false,
    DateTime? createdAt,
    this.description, // <-- Add this
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    TaskPriority? priority,
    bool? isCompleted,
    String? description, // <-- Add this
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      description: description ?? this.description, // <-- Add this
    );
  }
}
