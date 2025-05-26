import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:adhd_task_triage/screens/home_screen.dart';
import 'package:adhd_task_triage/models/task.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with the correct directory for all platforms
  Directory appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  // Register adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());

  // Open the tasks box
  await Hive.openBox<Task>('tasks');

  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADHD Task Triage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF181A20),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF23272F),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF23272F),
          foregroundColor: Colors.white,
        ),
        textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

class TaskProvider with ChangeNotifier {
  late final Box<Task> _taskBox;
  List<Task> _tasks = [];

  TaskProvider() {
    _taskBox = Hive.box<Task>('tasks');
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

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

  void addTask(Task task) {
    _taskBox.add(task);
    _loadTasks();
  }

  void editTask(String id, String newTitle, String? newDescription) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final newTask = task.copyWith(
        title: newTitle,
        description: newDescription,
      );
      _taskBox.putAt(index, newTask);
      _loadTasks();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final newTask = task.copyWith(
        isCompleted: !task.isCompleted,
      );
      _taskBox.putAt(index, newTask);
      _loadTasks();
    }
  }

  void deleteTask(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _taskBox.deleteAt(index);
      _loadTasks();
    }
  }
}
