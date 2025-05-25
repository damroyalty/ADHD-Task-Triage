import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhd_task_triage/screens/home_screen.dart';
import 'package:adhd_task_triage/models/task.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
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
      debugShowCheckedModeBanner:
          false, // Add this line to remove the debug banner
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
  final List<Task> _tasks = [];

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
    _tasks.add(task);
    notifyListeners();
  }

  void editTask(String id, String newTitle, String? newDescription) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        title: newTitle,
        description: newDescription,
      );
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
