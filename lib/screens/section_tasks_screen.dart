import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhd_task_triage/models/task.dart';
import 'package:adhd_task_triage/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class SectionTasksScreen extends StatefulWidget {
  final String title;
  final Color color;
  final List<Task> tasks;
  const SectionTasksScreen({
    super.key,
    required this.title,
    required this.color,
    required this.tasks,
  });
  @override
  State<SectionTasksScreen> createState() => _SectionTasksScreenState();
}

class _SectionTasksScreenState extends State<SectionTasksScreen> {
  late List<Task> _orderedTasks;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TaskProvider>(context, listen: false);
    if (widget.title == 'MUST-DO') {
      _orderedTasks = provider.mustDoTasks;
    } else if (widget.title == 'COULD-DO') {
      _orderedTasks = provider.couldDoTasks;
    } else if (widget.title == 'DONE') {
      _orderedTasks = provider.completedTasks;
    } else {
      _orderedTasks = widget.tasks;
    }
  }

  void _showTaskInfoDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: widget.color.withOpacity(0.82),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task.title,
                style: GoogleFonts.baloo2(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              if (task.description != null && task.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    task.description!,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.85),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
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
            if (widget.title.toUpperCase() == 'MUST-DO')
              _GlowingAnimatedSectionTitle(
                text: 'MUST-DO',
                color1: const Color.fromARGB(255, 255, 72, 69),
                color2: Colors.redAccent,
                glowColor: Colors.redAccent,
                glowStrength: 1.0,
              )
            else if (widget.title.toUpperCase() == 'COULD-DO')
              _GlowingAnimatedSectionTitle(
                text: 'COULD-DO',
                color1: const Color.fromARGB(255, 42, 155, 247),
                color2: Colors.blueAccent,
                glowColor: Colors.blueAccent,
                glowStrength: 1.0,
              )
            else if (widget.title.toUpperCase() == 'DONE')
              Text(
                'DONE',
                style: GoogleFonts.baloo2(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              )
            else
              Text(
                widget.title,
                style: GoogleFonts.baloo2(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const _AnimatedADHDBackground(),
          SafeArea(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
              itemCount: _orderedTasks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _orderedTasks.removeAt(oldIndex);
                  _orderedTasks.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final task = _orderedTasks[index];
                return ListTile(
                  key: ValueKey(task.id),
                  title: Text(
                    task.title,
                    style: GoogleFonts.montserrat(color: Colors.white),
                  ),
                  subtitle: task.description != null
                      ? Text(
                          task.description!,
                          style: GoogleFonts.montserrat(color: Colors.white70),
                        )
                      : null,
                  trailing: (widget.title == 'MUST-DO' || widget.title == 'COULD-DO')
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: widget.title == 'MUST-DO'
                                  ? Colors.redAccent
                                  : Colors.blueAccent,
                              tooltip: 'Edit',
                              onPressed: () {
                                final titleController = TextEditingController(text: task.title);
                                final descController = TextEditingController(text: task.description ?? "");
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: const Color(0xFF23272F),
                                      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                                      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                                      title: Text('Edit Task', style: TextStyle(color: Colors.white)),
                                      content: SizedBox(
                                        width: 350,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: titleController,
                                              style: const TextStyle(color: Colors.white),
                                              decoration: InputDecoration(
                                                labelText: 'Title',
                                                labelStyle: const TextStyle(color: Colors.white70),
                                                filled: true,
                                                fillColor: const Color(0xFF23272F),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.cyanAccent, width: 2.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 18),
                                            TextField(
                                              controller: descController,
                                              style: const TextStyle(color: Colors.white),
                                              decoration: InputDecoration(
                                                labelText: 'Description (optional)',
                                                labelStyle: const TextStyle(color: Colors.white70),
                                                filled: true,
                                                fillColor: const Color(0xFF23272F),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.cyanAccent, width: 2.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              maxLines: 5,
                                              minLines: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.cyanAccent,
                                            foregroundColor: Colors.black,
                                          ),
                                          child: const Text('Save'),
                                          onPressed: () {
                                            Provider.of<TaskProvider>(context, listen: false).editTask(
                                              task.id,
                                              titleController.text,
                                              descController.text.isEmpty ? null : descController.text,
                                            );
                                            setState(() {
                                              _orderedTasks[index] = task.copyWith(
                                                title: titleController.text,
                                                description: descController.text.isEmpty ? null : descController.text,
                                              );
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: widget.title == 'MUST-DO'
                                  ? Colors.redAccent
                                  : Colors.blueAccent,
                              tooltip: 'Delete',
                              onPressed: () {
                                Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
                                setState(() {
                                  _orderedTasks.removeAt(index);
                                });
                              },
                            ),
                          ],
                        )
                      : null,
                  onTap: () => _showTaskInfoDialog(context, task),
                );
              },
            ),
          ),
        ],
      ),
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
                        blob.color.withOpacity(0.23),
                        blob.color.withOpacity(0.11),
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

class _GlowingAnimatedSectionTitle extends StatefulWidget {
  final String text;
  final Color color1;
  final Color color2;
  final Color glowColor;
  final double glowStrength;
  const _GlowingAnimatedSectionTitle({
    required this.text,
    required this.color1,
    required this.color2,
    required this.glowColor,
    this.glowStrength = 1.0,
  });

  @override
  State<_GlowingAnimatedSectionTitle> createState() =>
      _GlowingAnimatedSectionTitleState();
}

class _GlowingAnimatedSectionTitleState
    extends State<_GlowingAnimatedSectionTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _colorAnim = ColorTween(
      begin: widget.color1,
      end: widget.color2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
      builder: (context, child) {
        final glowOpacity = (0.95 * _glowAnim.value * widget.glowStrength)
            .clamp(0.0, 1.0);
        return Text(
          widget.text,
          textAlign: TextAlign.center,
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
            color: _colorAnim.value,
            shadows: [
              Shadow(
                color: widget.glowColor.withOpacity(glowOpacity),
                blurRadius: 120,
              ),
              Shadow(
                color: widget.glowColor.withOpacity(glowOpacity),
                blurRadius: 60,
              ),
              Shadow(
                color: widget.glowColor.withOpacity(glowOpacity * 0.7),
                blurRadius: 24,
              ),
            ],
          ),
        );
      },
    );
  }
}
