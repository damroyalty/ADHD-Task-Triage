import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:adhd_task_triage/models/task.dart';
import 'package:adhd_task_triage/main.dart';

class TaskList extends StatefulWidget {
  final List<Task> tasks;
  final Color color;

  const TaskList({super.key, required this.tasks, required this.color});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<bool> _showCelebration;
  late List<GlobalKey> _tileKeys;
  late List<GlobalKey> _checkboxKeys;
  OverlayEntry? _particleOverlay;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.tasks.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      ),
    );
    _animations = _controllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 1.15)
              .chain(CurveTween(curve: Curves.easeInOutCubicEmphasized))
              .animate(controller),
        )
        .toList();
    _showCelebration = List.filled(widget.tasks.length, false);
    _tileKeys = List.generate(widget.tasks.length, (_) => GlobalKey());
    _checkboxKeys = List.generate(widget.tasks.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant TaskList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tasks.length != _controllers.length) {
      for (final c in _controllers) {
        c.dispose();
      }
      _initAnimations();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _removeParticleOverlay();
    super.dispose();
  }

  void _removeParticleOverlay() {
    _particleOverlay?.remove();
    _particleOverlay = null;
  }

  void _showParticleAnimationAt(GlobalKey key, Color color) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final overlay = Overlay.of(context);
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _removeParticleOverlay();

    _particleOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx + size.width / 2 - 24,
          top: position.dy + size.height / 2 - 24,
          child: IgnorePointer(
            child: _ParticleBurstOverlay(
              color: color,
              onCompleted: _removeParticleOverlay,
            ),
          ),
        );
      },
    );
    overlay.insert(_particleOverlay!);
  }

  void _showParticleAnimationAtPosition(Offset globalPosition, Color color) {
    final overlay = Overlay.of(context);
    _removeParticleOverlay();
    _particleOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: globalPosition.dx - 24,
          top: globalPosition.dy - 24,
          child: IgnorePointer(
            child: _ParticleBurstOverlay(
              color: color,
              onCompleted: _removeParticleOverlay,
            ),
          ),
        );
      },
    );
    overlay.insert(_particleOverlay!);
  }

  void _playCelebrate(int index) async {
    if (index < 0 || index >= _controllers.length) return;
    if (_controllers[index].isAnimating) return;

    final isMustDo = widget.tasks[index].priority == TaskPriority.mustDo;
    if (!isMustDo) {
      _controllers[index].forward(from: 0.0);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted && index < _controllers.length) {
        _controllers[index].reverse();
      }
      return;
    }

    setState(() {
      _showCelebration[index] = true;
    });
    _controllers[index].forward(from: 0.0);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted && index < _controllers.length) {
      _controllers[index].reverse();
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted && index < _showCelebration.length) {
        setState(() {
          _showCelebration[index] = false;
        });
      }
    }
  }

  void _showEditDialog(Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description ?? "");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF23272F),
          title: const Text('Edit Task', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
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
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks here!',
          style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 12),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: widget.tasks.length,
          itemBuilder: (context, index) {
            final task = widget.tasks[index];
            return Stack(
              children: [
                AnimatedBuilder(
                  animation: _animations[index],
                  builder: (context, child) {
                    final isAnimating = _controllers[index].isAnimating;
                    return Transform.scale(
                      scale: isAnimating ? _animations[index].value : 1.0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: widget.color.withOpacity(0.25),
                            width: 1.2,
                          ),
                        ),
                        child: ListTile(
                          key: _tileKeys[index],
                          dense: true,
                          minVerticalPadding: 0,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          horizontalTitleGap: 8,
                          visualDensity: const VisualDensity(
                            horizontal: 0,
                            vertical: -4,
                          ),
                          tileColor: Colors.transparent,
                          leading: SizedBox(
                            width: 32,
                            height: 32,
                            child: Center(
                              child: Listener(
                                onPointerDown: (event) {
                                  // pointerdevice
                                  if (event.kind == PointerDeviceKind.mouse ||
                                      event.kind == PointerDeviceKind.touch) {
                                    _showParticleAnimationAtPosition(
                                      event.position,
                                      widget.color,
                                    );
                                  }
                                },
                                child: Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (value) {
                                    if (value == true && !task.isCompleted) {
                                      _playCelebrate(index);
                                    }
                                    Provider.of<TaskProvider>(
                                      context,
                                      listen: false,
                                    ).toggleTaskCompletion(task.id);
                                  },
                                  fillColor:
                                      WidgetStateProperty.resolveWith<Color>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return widget.color;
                                        }
                                        return Colors.white24;
                                      }),
                                  checkColor: Colors.white,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(
                                    horizontal: 0,
                                    vertical: -4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                task.title,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationThickness: task.isCompleted
                                      ? 2.5
                                      : 1.0,
                                  decorationColor: task.isCompleted
                                      ? widget.color.withOpacity(0.85)
                                      : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if ((task.description ?? "").isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 1.0),
                                  child: Text(
                                    task.description!,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (_showCelebration[index])
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: _ModernCelebrate(),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.cyanAccent,
                                  size: 20,
                                ),
                                tooltip: 'Edit',
                                onPressed: () => _showEditDialog(task),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: widget.color,
                                  size: 20,
                                ),
                                tooltip: 'Delete',
                                onPressed: () {
                                  Provider.of<TaskProvider>(
                                    context,
                                    listen: false,
                                  ).deleteTask(task.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ParticleBurstOverlay extends StatefulWidget {
  final Color color;
  final VoidCallback onCompleted;
  const _ParticleBurstOverlay({required this.color, required this.onCompleted});

  @override
  State<_ParticleBurstOverlay> createState() => _ParticleBurstOverlayState();
}

class _ParticleBurstOverlayState extends State<_ParticleBurstOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });
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
        final t = _anim.value;
        return SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(12, (i) {
              final angle = 2 * pi * i / 12;
              final radius = 20.0 * t;
              return Positioned(
                left: 24 + cos(angle) * radius,
                top: 24 + sin(angle) * radius,
                child: Opacity(
                  opacity: 1.0 - t,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _ModernCelebrate extends StatefulWidget {
  @override
  State<_ModernCelebrate> createState() => _ModernCelebrateState();
}

class _ModernCelebrateState extends State<_ModernCelebrate>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
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
        final t = _anim.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Opacity(
              opacity: (1 - t).clamp(0.0, 1.0),
              child: Container(
                width: 36 + 32 * t,
                height: 36 + 32 * t,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.15 * (1 - t)),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Opacity(
              opacity: t,
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.cyanAccent.withOpacity(0.8),
                size: 36 + 8 * t,
              ),
            ),
            ...List.generate(8, (i) {
              final angle = 2 * pi * i / 8;
              final radius = 24.0 * t;
              return Positioned(
                left: 18 + cos(angle) * radius,
                top: 18 + sin(angle) * radius,
                child: Opacity(
                  opacity: (1.0 - t).clamp(0.0, 1.0),
                  child: Icon(
                    Icons.star,
                    color: Colors.amberAccent.withOpacity(0.8),
                    size: 10 + 8 * (1 - t),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
