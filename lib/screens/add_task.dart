import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhd_task_triage/models/task.dart';
import 'package:adhd_task_triage/models/task_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math';

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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Stack(
          alignment: Alignment.center,
          children: [
            _FullTextGlow(
              text: 'Add New Task',
              fontSize: 24,
              glowColor1: Colors.deepPurpleAccent,
              glowColor2: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            AnimatedTextKit(
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
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const _AnimatedADHDBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.montserrat(
                          color: Colors.white70,
                        ),
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.white38,
                        ),
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
                        labelStyle: GoogleFonts.montserrat(
                          color: Colors.white70,
                        ),
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.white38,
                        ),
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final task = Task(
                            title: _titleController.text,
                            priority: _priority,
                            description: _descController.text.isEmpty
                                ? null
                                : _descController.text,
                          );

                          Provider.of<TaskProvider>(
                            context,
                            listen: false,
                          ).addTask(task);

                          if (!mounted) return;
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add Task'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                  widget.glowColor1.withAlpha(
                    (0.32 * _anim.value + 0.10).round(),
                  ),
                  widget.glowColor2.withAlpha(
                    (0.18 * (1 - _anim.value) + 0.08).round(),
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
                  ..color = widget.glowColor1.withAlpha(
                    ((0.55 + 0.35 * _anim.value) * 255).round(),
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
                  ..color = widget.glowColor2.withAlpha(
                    ((0.38 + 0.32 * (1 - _anim.value)) * 255).round(),
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

class _AnimatedADHDBackground extends StatefulWidget {
  const _AnimatedADHDBackground();

  @override
  State<_AnimatedADHDBackground> createState() =>
      _AnimatedADHDBackgroundState();
}

class _AnimatedADHDBackgroundState extends State<_AnimatedADHDBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<_BlobConfig> _blobs = [
    _BlobConfig(
      color: Colors.pinkAccent,
      size: 320,
      dx: 0.1,
      dy: 0.18,
      speed: 1.2,
      phase: 0.0,
    ),
    _BlobConfig(
      color: Colors.cyanAccent,
      size: 260,
      dx: 0.7,
      dy: 0.22,
      speed: 1.5,
      phase: 1.1,
    ),
    _BlobConfig(
      color: Colors.yellowAccent,
      size: 220,
      dx: 0.3,
      dy: 0.7,
      speed: 1.1,
      phase: 2.2,
    ),
    _BlobConfig(
      color: Colors.deepPurpleAccent,
      size: 280,
      dx: 0.8,
      dy: 0.75,
      speed: 1.3,
      phase: 3.3,
    ),
  ];

  double _startTime = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _controller = AnimationController(
      duration: const Duration(days: 365),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
        final time = (now - _startTime) / 14.0;
        return SizedBox.expand(
          child: Stack(
            children: _blobs.map((blob) {
              final t = (time * blob.speed + blob.phase);
              final angle = 2 * pi * t;
              final dx =
                  blob.dx +
                  0.18 * sin(angle) +
                  0.13 * sin(2.7 * angle + blob.phase) +
                  0.09 * cos(1.3 * angle + blob.phase * 1.7);
              final dy =
                  blob.dy +
                  0.18 * cos(angle) +
                  0.13 * cos(2.2 * angle + blob.phase) +
                  0.09 * sin(1.7 * angle + blob.phase * 2.1);
              return Positioned(
                left: dx * size.width,
                top: dy * size.height,
                child: Container(
                  width: blob.size,
                  height: blob.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        blob.color.withAlpha((0.23 * 255).round()),
                        blob.color.withAlpha((0.11 * 255).round()),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _BlobConfig {
  final Color color;
  final double size;
  final double dx;
  final double dy;
  final double speed;
  final double phase;
  const _BlobConfig({
    required this.color,
    required this.size,
    required this.dx,
    required this.dy,
    required this.speed,
    required this.phase,
  });
}
