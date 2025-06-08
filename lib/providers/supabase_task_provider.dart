import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> addTask(
    String title,
    String? description,
    TaskPriority priority,
  ) async {
    if (!_authService.isSignedIn) return;

    try {
      final taskData = {
        'title': title,
        'description': description,
        'priority': priority.name,
        'is_completed': false,
        'user_id': _authService.currentUser!.id,
        'created_at': DateTime.now().toIso8601String(),
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
