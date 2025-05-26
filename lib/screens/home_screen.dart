import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhd_task_triage/models/task.dart';
import 'package:adhd_task_triage/widgets/task_list.dart';
import 'add_task.dart';
import 'package:adhd_task_triage/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23272F),
        foregroundColor: Colors.white,
        title: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned.fill(
              child: Center(
                child: _FullTextGlow(
                  text: 'ADHD Task Triage',
                  fontSize: 28,
                  glowColor1: Colors.deepPurpleAccent,
                  glowColor2: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            Center(
              child: AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'ADHD Task Triage',
                    textStyle: GoogleFonts.baloo2(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    colors: [
                      Colors.pinkAccent,
                      Colors.cyanAccent,
                      Colors.yellowAccent,
                      Colors.deepPurpleAccent,
                    ],
                    speed: const Duration(milliseconds: 400),
                  ),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // must-do section
          PrioritySection(
            title: 'MUST-DO (1-3 MAX)',
            subtitle: 'What will wreck your future if not done today?',
            color: const Color.fromARGB(255, 255, 72, 69),
            tasks: context.watch<TaskProvider>().mustDoTasks,
          ),

          // could-do section
          PrioritySection(
            title: 'COULD-DO',
            subtitle: 'Nice to have but no disaster if skipped',
            color: const Color.fromARGB(255, 42, 155, 247),
            tasks: context.watch<TaskProvider>().couldDoTasks,
          ),

          // completed section
          PrioritySection(
            title: 'DONE',
            subtitle: 'Celebrate your wins!',
            color: const Color.fromARGB(255, 77, 168, 82),
            tasks: context.watch<TaskProvider>().completedTasks,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        backgroundColor: const Color(0xFF23272F),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PrioritySection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final List<Task> tasks;

  const PrioritySection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.22),
              color.withOpacity(0.10),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.22), width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText(
                          title,
                          textStyle: GoogleFonts.baloo2(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 1.2,
                          ),
                          speed: const Duration(milliseconds: 120),
                        ),
                      ],
                      repeatForever: true,
                      isRepeatingAnimation: true,
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: color.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TaskList(tasks: tasks, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NaturalGlow extends StatefulWidget {
  final double width;
  final double height;
  final Color glowColor1;
  final Color glowColor2;
  const _NaturalGlow({
    required this.width,
    required this.height,
    required this.glowColor1,
    required this.glowColor2,
  });

  @override
  State<_NaturalGlow> createState() => _NaturalGlowState();
}

class _NaturalGlowState extends State<_NaturalGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.centerLeft,
                radius: 1.1,
                colors: [
                  widget.glowColor1.withOpacity(0.32 * _anim.value + 0.10),
                  widget.glowColor2.withOpacity(
                    0.18 * (1 - _anim.value) + 0.08,
                  ),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FullTextGlow extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color glowColor1;
  final Color glowColor2;
  final FontWeight fontWeight;
  final double letterSpacing;

  const _FullTextGlow({
    required this.text,
    required this.fontSize,
    required this.glowColor1,
    required this.glowColor2,
    required this.fontWeight,
    required this.letterSpacing,
  });

  @override
  State<_FullTextGlow> createState() => _FullTextGlowState();
}

class _FullTextGlowState extends State<_FullTextGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Text(
              widget.text,
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
                letterSpacing: widget.letterSpacing,
                foreground: Paint()
                  ..color = widget.glowColor1.withOpacity(
                    0.55 + 0.35 * _anim.value,
                  )
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
              ),
            ),
            Text(
              widget.text,
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
                letterSpacing: widget.letterSpacing,
                foreground: Paint()
                  ..color = widget.glowColor2.withOpacity(
                    0.38 + 0.32 * (1 - _anim.value),
                  )
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
              ),
            ),
          ],
        );
      },
    );
  }
}
