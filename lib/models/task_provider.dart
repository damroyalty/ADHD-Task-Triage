import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'task.dart';

class TaskProvider with ChangeNotifier {
  Box<Task>? _taskBox;
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  List<Task> get mustDoTasks => _tasks
      .where(
        (task) => task.priority == TaskPriority.mustDo && !task.isCompleted,
      )
      .toList();

  List<Task> get couldDoTasks => _tasks
      .where(
        (task) => task.priority == TaskPriority.couldDo && !task.isCompleted,
      )
      .toList();

  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _taskBox = await Hive.openBox<Task>('tasks');
    _tasks = _taskBox!.values.toList().cast<Task>();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    if (_taskBox == null) await _loadTasks();
    await _taskBox!.put(task.id, task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> editTask(
    String id,
    String newTitle,
    String? newDescription,
  ) async {
    if (_taskBox == null) return;

    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) return;

    final updatedTask = _tasks[taskIndex].copyWith(
      title: newTitle,
      description: newDescription,
    );

    await _taskBox!.put(id, updatedTask);
    _tasks[taskIndex] = updatedTask;
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String id) async {
    if (_taskBox == null) return;

    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    task.isCompleted = !task.isCompleted;

    await _taskBox!.put(id, task);
    _tasks[taskIndex] = task;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    if (_taskBox == null) return;

    await _taskBox!.delete(id);
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  @override
  void dispose() {
    _taskBox?.close();
    super.dispose();
  }
}
