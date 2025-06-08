import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:adhd_task_triage/models/task.dart';
import 'package:adhd_task_triage/widgets/task_list.dart';
import 'add_task.dart';
import 'package:adhd_task_triage/models/task_provider.dart';
import 'package:adhd_task_triage/services/database_test_service.dart';
import 'package:adhd_task_triage/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'section_tasks_screen.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showTaskInfoDialog(BuildContext context, Task task, Color color) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: color.withValues(alpha: 0.82),
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
                  backgroundColor: Colors.white.withAlpha((0.85 * 255).round()),
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

  void _handleLogout(BuildContext context) async {
    try {
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF2A2D36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.baloo2(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.montserrat(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Logout',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
      if (shouldLogout == true) {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.signOut();
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2D36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Error',
              style: GoogleFonts.baloo2(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Failed to logout: ${e.toString()}',
              style: GoogleFonts.montserrat(color: Colors.white70),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.85),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showSupportPopup(BuildContext context) {
    final links = [
      {
        'label': 'PayPal',
        'url': 'https://paypal.me/damroyaltyxxii',
        'icon': Icons.attach_money,
      },
      {
        'label': 'Instagram',
        'url': 'https://www.instagram.com/damroyalty',
        'icon': Icons.camera_alt,
      },
      {
        'label': 'X/Twitter',
        'url': 'https://www.x.com/damroyalty',
        'icon': Icons.alternate_email,
      },
      {
        'label': 'GitHub',
        'url': 'https://www.github.com/damroyalty',
        'icon': Icons.code,
      },
      {
        'label': 'Linktree',
        'url': 'https://linktr.ee/damroyalty',
        'icon': Icons.link,
      },
      {
        'label': 'Twitch',
        'url': 'https://www.twitch.tv/devroyalty',
        'icon': Icons.videogame_asset,
      },
      {
        'label': 'Discord',
        'url': 'https://discord.gg/kDs2mmQwwS',
        'icon': Icons.forum,
      },
    ];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(
          0xFF23272F,
        ).withAlpha((0.95 * 255).round()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Support & Socials',
                style: GoogleFonts.baloo2(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 18,
                runSpacing: 12,
                children: links.map((link) {
                  return IconButton(
                    icon: Icon(
                      link['icon'] as IconData,
                      color: Colors.cyanAccent,
                      size: 32,
                    ),
                    tooltip: link['label'] as String,
                    onPressed: () async {
                      final url = Uri.parse(link['url'] as String);
                      try {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {}
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for your support!',
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withAlpha((0.85 * 255).round()),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
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
      backgroundColor: const Color(0xFF181A20),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.green),
              tooltip: 'Test Database',
              onPressed: () async {
                await DatabaseTestService.testDatabaseConnection();
                await DatabaseTestService.testTaskCreation();
              },
            ),
        ],
        title: Stack(
          alignment: Alignment.center,
          children: [
            _FullTextGlow(
              text: 'ADHD Task Triage',
              fontSize: 28,
              glowColor1: Colors.deepPurpleAccent,
              glowColor2: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            AnimatedTextKit(
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
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const _AnimatedADHDBackground(),
          SafeArea(
            child: Column(
              children: [
                PrioritySection(
                  title: 'MUST-DO (1-3 MAX)',
                  subtitle: 'what will wreck your future if not done today?',
                  color: const Color.fromARGB(255, 255, 72, 69),
                  tasks: context.watch<TaskProvider>().mustDoTasks,
                  onTaskTap: (task) => _showTaskInfoDialog(
                    context,
                    task,
                    const Color.fromARGB(255, 255, 72, 69),
                  ),
                  sectionNav: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SectionTasksScreen(
                          title: 'MUST-DO',
                          color: const Color.fromARGB(255, 255, 72, 69),
                          tasks: context.read<TaskProvider>().mustDoTasks,
                        ),
                      ),
                    );
                  },
                ),
                PrioritySection(
                  title: 'COULD-DO',
                  subtitle: 'could be done, but no disaster if skipped',
                  color: const Color.fromARGB(255, 42, 155, 247),
                  tasks: context.watch<TaskProvider>().couldDoTasks,
                  onTaskTap: (task) => _showTaskInfoDialog(
                    context,
                    task,
                    const Color.fromARGB(255, 42, 155, 247),
                  ),
                  sectionNav: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SectionTasksScreen(
                          title: 'COULD-DO',
                          color: const Color.fromARGB(255, 42, 155, 247),
                          tasks: context.read<TaskProvider>().couldDoTasks,
                        ),
                      ),
                    );
                  },
                ),
                PrioritySection(
                  title: 'DONE',
                  subtitle:
                      'dont get complacent just because you completed a few tasks!',
                  color: const Color.fromARGB(255, 77, 168, 82),
                  tasks: context.watch<TaskProvider>().completedTasks,
                  onTaskTap: (task) => _showTaskInfoDialog(
                    context,
                    task,
                    const Color.fromARGB(255, 77, 168, 82),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.pinkAccent,
                      size: 32,
                    ),
                    tooltip: 'Support & Socials',
                    onPressed: () => _showSupportPopup(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 1.0, right: 5.0),
        child: SizedBox(
          width: 44,
          height: 44,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTaskScreen()),
              );
            },
            backgroundColor: const Color(0xFF23272F),
            foregroundColor: Colors.white,
            child: const Icon(Icons.add, size: 24),
          ),
        ),
      ),
    );
  }
}

class PrioritySection extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color color;
  final List<Task> tasks;
  final void Function(Task)? onTaskTap;
  final VoidCallback? sectionNav;

  const PrioritySection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.tasks,
    this.onTaskTap,
    this.sectionNav,
  });

  @override
  State<PrioritySection> createState() => _PrioritySectionState();
}

class _PrioritySectionState extends State<PrioritySection> {
  late List<Task> _orderedTasks;

  @override
  void initState() {
    super.initState();
    _orderedTasks = List.from(widget.tasks);
  }

  @override
  void didUpdateWidget(covariant PrioritySection old) {
    super.didUpdateWidget(old);
    if (widget.tasks != old.tasks) {
      _orderedTasks = List.from(widget.tasks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              widget.color.withValues(alpha: 0.22),
              widget.color.withValues(alpha: 0.10),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.18),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: widget.color.withValues(alpha: 0.22),
            width: 1.2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: GoogleFonts.baloo2(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.color,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (widget.sectionNav != null)
                          IconButton(
                            icon: Icon(
                              Icons.open_in_new,
                              color: widget.color.withValues(alpha: 0.8),
                              size: 20,
                            ),
                            tooltip: 'View all',
                            onPressed: widget.sectionNav,
                          ),
                      ],
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: widget.color.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TaskList(
                  tasks: _orderedTasks,
                  color: widget.color,
                  onTaskTap: widget.onTaskTap,
                  reorderable: true,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final t = _orderedTasks.removeAt(oldIndex);
                      _orderedTasks.insert(newIndex, t);
                    });
                  },
                ),
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
                  widget.glowColor1.withValues(
                    alpha: 0.32 * _anim.value + 0.10,
                  ),
                  widget.glowColor2.withValues(
                    alpha: 0.18 * (1 - _anim.value) + 0.08,
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
                    (0.55 + 0.35 * _anim.value * 255).round(),
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
                    (0.38 + 0.32 * (1 - _anim.value) * 255).round(),
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
