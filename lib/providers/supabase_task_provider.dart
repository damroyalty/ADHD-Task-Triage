import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'dart:io' show Platform;
import '../models/task.dart';
import '../services/auth_service.dart';

class SupabaseTaskProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  SupabaseTaskProvider(this._authService) {
    _authService.addListener(_onAuthChanged);
    if (_authService.isSignedIn) {
      loadTasks();
    }
  }

  void _onAuthChanged() {
    if (_authService.isSignedIn) {
      loadTasks();
    } else {
      _tasks.clear();
      notifyListeners();
    }
  }

  Future<void> loadTasks() async {
    if (!_authService.isSignedIn) return;

    _setLoading(true);
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', _authService.currentUser!.id)
          .order('created_at', ascending: false);

      _tasks = (response as List<dynamic>)
          .map((taskData) => Task.fromJson(taskData))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Error loading tasks: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTask(Task task) async {
    if (!_authService.isSignedIn) return;

    try {
      final taskData = {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'priority': task.priority.name,
        'is_completed': task.isCompleted,
        'user_id': _authService.currentUser!.id,
        'created_at': task.createdAt.toIso8601String(),
      };
      final response = await _supabase
          .from('tasks')
          .insert(taskData)
          .select()
          .single();

      final newTask = Task.fromJson(response);
      _tasks.insert(0, newTask);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> editTask(String id, String title, String? description) async {
    if (!_authService.isSignedIn) return;

    try {
      await _supabase
          .from('tasks')
          .update({'title': title, 'description': description})
          .eq('id', id)
          .eq('user_id', _authService.currentUser!.id);

      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          title: title,
          description: description,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Error editing task: $e');
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    if (!_authService.isSignedIn) return;

    try {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index == -1) return;

      final newCompletionStatus = !_tasks[index].isCompleted;

      await _supabase
          .from('tasks')
          .update({'is_completed': newCompletionStatus})
          .eq('id', id)
          .eq('user_id', _authService.currentUser!.id);

      _tasks[index] = _tasks[index].copyWith(isCompleted: newCompletionStatus);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Error toggling task completion: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    if (!_authService.isSignedIn) return;

    try {
      await _supabase
          .from('tasks')
          .delete()
          .eq('id', id)
          .eq('user_id', _authService.currentUser!.id);

      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Error deleting task: $e');
      rethrow;
    }
  }

  Future<List<Task>> checkLocalTasks() async {
    try {
      if (kDebugMode) print('🔍 Checking for local tasks...');

      if (!Platform.isAndroid && !Platform.isIOS) {
        if (kDebugMode)
          print(
            'ℹ️ Local task migration is only available on mobile platforms',
          );
        return [];
      }

      final taskBox = await Hive.openBox<Task>('tasks');
      final localTasks = taskBox.values.toList();

      if (kDebugMode) print('📱 Found ${localTasks.length} local tasks');

      return localTasks;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking local tasks: $e');
      return [];
    }
  }

  Future<void> removeDuplicateTasks() async {
    if (!_authService.isSignedIn) return;

    try {
      if (kDebugMode) print('🔄 Checking for duplicate tasks...');

      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', _authService.currentUser!.id)
          .order('created_at');

      final tasks = (response as List<dynamic>)
          .map((data) => Task.fromJson(data))
          .toList();

      final Map<String, List<Task>> taskGroups = {};

      for (final task in tasks) {
        final key = '${task.title}_${task.priority.name}_${task.isCompleted}';
        taskGroups[key] ??= [];
        taskGroups[key]!.add(task);
      }

      final List<String> idsToDelete = [];
      int duplicateCount = 0;

      for (final group in taskGroups.values) {
        if (group.length > 1) {
          group.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          for (int i = 1; i < group.length; i++) {
            idsToDelete.add(group[i].id);
            duplicateCount++;
          }
        }
      }

      if (idsToDelete.isEmpty) {
        if (kDebugMode) print('✅ No duplicate tasks found');
        return;
      }

      if (kDebugMode) print('🗑️ Removing $duplicateCount duplicate tasks...');

      for (final id in idsToDelete) {
        await _supabase.from('tasks').delete().eq('id', id);
      }

      await loadTasks();

      if (kDebugMode)
        print('✅ Successfully removed $duplicateCount duplicate tasks!');
    } catch (e) {
      if (kDebugMode) print('❌ Error removing duplicates: $e');
      rethrow;
    }
  }

  Future<void> migrateLocalTasksToCloud() async {
    if (!_authService.isSignedIn) {
      if (kDebugMode) print('❌ User not signed in - cannot migrate tasks');
      return;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      if (kDebugMode)
        print('ℹ️ Local task migration is only available on mobile platforms');
      throw Exception('Migration is only available on mobile devices');
    }

    try {
      if (kDebugMode)
        print('🔄 Starting task migration from local to cloud...');

      final taskBox = await Hive.openBox<Task>('tasks');
      final localTasks = taskBox.values.toList();

      if (localTasks.isEmpty) {
        if (kDebugMode) print('ℹ️ No local tasks found to migrate');
        return;
      }

      if (kDebugMode)
        print('📱 Found ${localTasks.length} local tasks to migrate');

      final existingCloudTasks = await _supabase
          .from('tasks')
          .select('id')
          .eq('user_id', _authService.currentUser!.id);

      final existingIds = (existingCloudTasks as List<dynamic>)
          .map((task) => task['id'] as String)
          .toSet();

      final tasksToMigrate = localTasks
          .where((task) => !existingIds.contains(task.id))
          .toList();

      if (tasksToMigrate.isEmpty) {
        if (kDebugMode) print('ℹ️ All local tasks already exist in cloud');
        await loadTasks();
        return;
      }

      if (kDebugMode)
        print(
          '⬆️ Uploading ${tasksToMigrate.length} new tasks to cloud...',
        );
      final taskDataList = tasksToMigrate
          .map(
            (task) => {
              'title': task.title,
              'description': task.description,
              'priority': task.priority.name,
              'is_completed': task.isCompleted,
              'user_id': _authService.currentUser!.id,
              'created_at': task.createdAt.toIso8601String(),
            },
          )
          .toList();

      await _supabase.from('tasks').insert(taskDataList);

      await loadTasks();

      if (kDebugMode)
        print(
          '✅ Successfully migrated ${tasksToMigrate.length} tasks to cloud!',
        );
    } catch (e) {
      _error = 'Migration failed: $e';
      if (kDebugMode) print('❌ Task migration failed: $e');
      rethrow;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }
}
