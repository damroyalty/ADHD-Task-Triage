import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhd_task_triage/models/task.dart';
import 'package:adhd_task_triage/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskPriority _priority = TaskPriority.mustDo;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned.fill(
              child: Center(
                child: _FullTextGlow(
                  text: 'Add New Task',
                  fontSize: 24,
                  glowColor1: Colors.deepPurpleAccent,
                  glowColor2: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Center(
              child: AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'Add New Task',
                    textStyle: GoogleFonts.baloo2(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
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
        backgroundColor: const Color(0xFF23272F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: const OutlineInputBorder(),
                  labelStyle: GoogleFonts.montserrat(color: Colors.white70),
                  hintStyle: GoogleFonts.montserrat(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF23272F),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  border: const OutlineInputBorder(),
                  labelStyle: GoogleFonts.montserrat(color: Colors.white70),
                  hintStyle: GoogleFonts.montserrat(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF23272F),
                ),
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 13,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Priority:',
                style: GoogleFonts.montserrat(color: Colors.white70),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text(
                      'MUST-DO',
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                    selected: _priority == TaskPriority.mustDo,
                    selectedColor: Colors.red[300],
                    backgroundColor: const Color(0xFF23272F),
                    onSelected: (selected) {
                      setState(() {
                        _priority = TaskPriority.mustDo;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: Text(
                      'COULD-DO',
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                    selected: _priority == TaskPriority.couldDo,
                    selectedColor: Colors.blue[300],
                    backgroundColor: const Color(0xFF23272F),
                    onSelected: (selected) {
                      setState(() {
                        _priority = TaskPriority.couldDo;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23272F),
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Provider.of<TaskProvider>(context, listen: false).addTask(
                      Task(
                        title: _titleController.text,
                        priority: _priority,
                        description: _descController.text.isEmpty
                            ? null
                            : _descController.text,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Task'),
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
