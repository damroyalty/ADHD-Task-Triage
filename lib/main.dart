import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:adhd_task_triage/models/task.dart';
import 'package:adhd_task_triage/models/task_provider.dart';
import 'package:adhd_task_triage/providers/supabase_task_provider.dart';
import 'package:adhd_task_triage/services/auth_service.dart';
import 'package:adhd_task_triage/screens/home_screen.dart';
import 'package:adhd_task_triage/screens/login_screen.dart';
import 'package:adhd_task_triage/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  await Hive.openBox<Task>('tasks');
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProxyProvider2<
          AuthService,
          TaskProvider,
          SupabaseTaskProvider
        >(
          create: (context) =>
              SupabaseTaskProvider(context.read<AuthService>()),
          update: (context, authService, taskProvider, previous) =>
              previous ?? SupabaseTaskProvider(authService),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
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
              textTheme: GoogleFonts.montserratTextTheme(
                ThemeData.dark().textTheme,
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: authService.isSignedIn
                ? const HomeScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
