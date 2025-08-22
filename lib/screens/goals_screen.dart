import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

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
              final angle = 2 * 3.14159 * t;
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

class Goal {
  String title;
  String priority;
  Color color;
  String targetDate;
  List<String> steps;
  String measurement;
  String term;
  Goal({
    required this.title,
    required this.priority,
    required this.color,
    required this.targetDate,
    required this.steps,
    required this.measurement,
    required this.term,
  });
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final List<Goal> _goals = [];

  void _addOrEditGoal({Goal? goal, int? index}) async {
    final titleController = TextEditingController(text: goal?.title ?? '');
    final dateController = TextEditingController(text: goal?.targetDate ?? '');
    final measurementController = TextEditingController(
      text: goal?.measurement ?? '',
    );
    final steps = List<String>.from(goal?.steps ?? []);
    String priority = goal?.priority ?? 'medium';
    Color color = goal?.color ?? Colors.yellow;
    String term = goal?.term ?? 'Short term 0-6 months';
    await showDialog(
      context: context,
      builder: (context) {
        List<String> localSteps = List<String>.from(steps);
        String localPriority = priority;
        Color localColor = color;
        String localTerm = term;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF23272F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                index == null ? 'Add Goal' : 'Edit Goal',
                style: GoogleFonts.baloo2(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Term:',
                          style: GoogleFonts.montserrat(color: Colors.white70),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: localTerm,
                          dropdownColor: const Color(0xFF23272F),
                          items: const [
                            DropdownMenuItem(
                              value: 'Short term 0-6 months',
                              child: Text(
                                'Short term 0-6 months',
                                style: TextStyle(color: Colors.cyanAccent),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Medium term 6 months - 2 years',
                              child: Text(
                                'Medium term 6 months - 2 years',
                                style: TextStyle(color: Colors.amber),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Long term 2+ years',
                              child: Text(
                                'Long term 2+ years',
                                style: TextStyle(
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            setStateDialog(() {
                              localTerm = val!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Priority:',
                          style: GoogleFonts.montserrat(color: Colors.white70),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: localPriority,
                          dropdownColor: const Color(0xFF23272F),
                          items: [
                            DropdownMenuItem(
                              value: 'high',
                              child: Text(
                                'High',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'medium',
                              child: Text(
                                'Medium',
                                style: TextStyle(color: Colors.yellow[700]),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'low',
                              child: Text(
                                'Low',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            setStateDialog(() {
                              localPriority = val!;
                              localColor = val == 'high'
                                  ? Colors.red
                                  : val == 'medium'
                                  ? Colors.yellow
                                  : Colors.green;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dateController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Target Date',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: measurementController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Measurement of Success',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Action Steps:',
                      style: GoogleFonts.montserrat(color: Colors.white70),
                    ),
                    ...localSteps.asMap().entries.map((entry) {
                      int i = entry.key;
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                text: entry.value,
                              ),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Step ${i + 1}',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                              onChanged: (val) {
                                setStateDialog(() {
                                  localSteps[i] = val;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () {
                              setStateDialog(() {
                                localSteps.removeAt(i);
                              });
                            },
                          ),
                        ],
                      );
                    }),
                    TextButton(
                      child: const Text(
                        'Add Step',
                        style: TextStyle(color: Colors.cyanAccent),
                      ),
                      onPressed: () {
                        setStateDialog(() {
                          localSteps.add('');
                        });
                      },
                    ),
                  ],
                ),
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
                  child: Text(index == null ? 'Add' : 'Save'),
                  onPressed: () {
                    final newGoal = Goal(
                      title: titleController.text,
                      priority: localPriority,
                      color: localColor,
                      targetDate: dateController.text,
                      steps: List<String>.from(localSteps),
                      measurement: measurementController.text,
                      term: localTerm,
                    );
                    setState(() {
                      if (index == null) {
                        _goals.add(newGoal);
                      } else {
                        _goals[index] = newGoal;
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Goals',
              style: GoogleFonts.baloo2(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.deepPurpleAccent,
                shadows: [
                  Shadow(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const _AnimatedADHDBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Short Term Goals',
                    style: GoogleFonts.baloo2(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                      shadows: [
                        Shadow(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._goals
                      .where((g) => g.term == 'Short term 0-6 months')
                      .map(
                        (goal) => Dismissible(
                          key: ValueKey(
                            'short-' + goal.title + goal.targetDate,
                          ),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            color: Colors.redAccent,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            setState(() {
                              _goals.remove(goal);
                            });
                          },
                          child: GestureDetector(
                            onTap: () => _addOrEditGoal(
                              goal: goal,
                              index: _goals.indexOf(goal),
                            ),
                            child: _goalCard(goal),
                          ),
                        ),
                      ),
                  const SizedBox(height: 24),
                  Text(
                    'Medium Term Goals',
                    style: GoogleFonts.baloo2(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      shadows: [
                        Shadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._goals
                      .where((g) => g.term == 'Medium term 6 months - 2 years')
                      .map(
                        (goal) => Dismissible(
                          key: ValueKey(
                            'medium-' + goal.title + goal.targetDate,
                          ),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            color: Colors.redAccent,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            setState(() {
                              _goals.remove(goal);
                            });
                          },
                          child: GestureDetector(
                            onTap: () => _addOrEditGoal(
                              goal: goal,
                              index: _goals.indexOf(goal),
                            ),
                            child: _goalCard(goal),
                          ),
                        ),
                      ),
                  const SizedBox(height: 24),
                  Text(
                    'Long Term Goals',
                    style: GoogleFonts.baloo2(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                      shadows: [
                        Shadow(
                          color: Colors.deepPurpleAccent.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._goals
                      .where((g) => g.term == 'Long term 2+ years')
                      .map(
                        (goal) => Dismissible(
                          key: ValueKey('long-' + goal.title + goal.targetDate),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            color: Colors.redAccent,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            setState(() {
                              _goals.remove(goal);
                            });
                          },
                          child: GestureDetector(
                            onTap: () => _addOrEditGoal(
                              goal: goal,
                              index: _goals.indexOf(goal),
                            ),
                            child: _goalCard(goal),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
        tooltip: 'Add Goal',
        onPressed: () => _addOrEditGoal(),
      ),
    );
  }

  Widget _goalCard(Goal goal) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: goal.color.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: goal.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  goal.title,
                  style: GoogleFonts.baloo2(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: goal.color,
                  ),
                ),
                const Spacer(),
                Text(
                  goal.priority.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: goal.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Term: ${goal.term}',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Target Date: ${goal.targetDate}',
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Action Steps:',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
            ...goal.steps.map(
              (s) => Padding(
                padding: const EdgeInsets.only(left: 12, top: 2),
                child: Text(
                  '• $s',
                  style: GoogleFonts.montserrat(fontSize: 13),
                ),
              ),
            ),
            if (goal.measurement.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Measurement of Success:',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 2),
                child: Text(
                  goal.measurement,
                  style: GoogleFonts.montserrat(fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
