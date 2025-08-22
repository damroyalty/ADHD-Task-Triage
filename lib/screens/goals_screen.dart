import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';

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
  String id;
  String title;
  String priority;
  int colorValue;
  String targetDate;
  List<String> steps;
  String measurement;
  String term;
  String userId;

  Goal({
    required this.id,
    required this.title,
    required this.priority,
    required this.colorValue,
    required this.targetDate,
    required this.steps,
    required this.measurement,
    required this.term,
    required this.userId,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'color_value': colorValue & 0xFFFFFF,
      'target_date': targetDate,
      'steps': steps,
      'measurement': measurement,
      'term': term,
      'user_id': userId,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    List<String> stepsDecoded = [];
    if (map['steps'] is String) {
      try {
        stepsDecoded = List<String>.from(
          (map['steps'] != null && map['steps'] != '')
              ? (map['steps'] is String
                    ? List<dynamic>.from(jsonDecode(map['steps']))
                    : map['steps'])
              : [],
        );
      } catch (e) {
        stepsDecoded = [];
      }
    } else if (map['steps'] is List) {
      stepsDecoded = List<String>.from(map['steps']);
    }
    String title = '';
    if (map.containsKey('title') && map['title'] != null) {
      title = map['title'].toString();
    } else if (map.containsKey('goal_title') && map['goal_title'] != null) {
      title = map['goal_title'].toString();
    } else {
      title = '[No Title]';
    }
    return Goal(
      id: map['id'] as String,
      title: title,
      priority: map['priority'] as String,
      colorValue: map['color_value'] as int,
      targetDate: map['target_date'] as String,
      steps: stepsDecoded,
      measurement: map['measurement'] as String? ?? '',
      term: map['term'] as String? ?? '',
      userId: map['user_id'] as String,
    );
  }
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;
  final String goalsTable = 'goals';

  String get _userId => _supabase.auth.currentUser?.id ?? '';

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
        List<TextEditingController> stepControllers = localSteps
            .map((s) => TextEditingController(text: s))
            .toList();
        String localPriority = priority;
        Color localColor = color;
        String localTerm = term;
        String localTitle = titleController.text;
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
                      onChanged: (val) {
                        setStateDialog(() {
                          localTitle = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Term:',
                          style: GoogleFonts.montserrat(color: Colors.white70),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: localTerm,
                            dropdownColor: const Color(0xFF23272F),
                            isExpanded: true,
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
                    ...stepControllers.asMap().entries.map((entry) {
                      int i = entry.key;
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: entry.value,
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
                                stepControllers.removeAt(i);
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
                          stepControllers.add(TextEditingController());
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
                  onPressed: () async {
                    final uuid = Uuid();
                    final newGoal = Goal(
                      id: goal?.id ?? uuid.v4(),
                      title: localTitle,
                      priority: localPriority,
                      colorValue: localColor.value,
                      targetDate: dateController.text,
                      steps: stepControllers.map((c) => c.text).toList(),
                      measurement: measurementController.text,
                      term: localTerm,
                      userId: _userId,
                    );
                    if (index == null) {
                      await _addGoalToSupabase(newGoal);
                    } else {
                      await _updateGoalInSupabase(newGoal);
                    }
                    await _loadGoalsFromSupabase();
                    if (mounted) setState(() {});
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

  Future<void> _loadGoalsFromSupabase() async {
    _isLoading = true;
    try {
      final response = await _supabase
          .from(goalsTable)
          .select()
          .eq('user_id', _userId);
      print('Supabase goals response:');
      print(response);
      _goals.clear();
      for (var item in response) {
        _goals.add(Goal.fromMap(item));
      }
      for (var g in _goals) {
        print('Loaded goal: id=${g.id}, title=${g.title}');
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _addGoalToSupabase(Goal goal) async {
    try {
      final goalMap = goal.toMap();
      goalMap['steps'] = goal.steps;
      await _supabase.from(goalsTable).insert(goalMap);
    } catch (e) {
      _error = e.toString();
      print('Error adding goal: $_error');
    }
  }

  Future<void> _updateGoalInSupabase(Goal goal) async {
    try {
      await _supabase
          .from(goalsTable)
          .update(goal.toMap())
          .eq('id', goal.id)
          .eq('user_id', _userId);
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> _deleteGoalFromSupabase(Goal goal) async {
    try {
      await _supabase
          .from(goalsTable)
          .delete()
          .eq('id', goal.id)
          .eq('user_id', _userId);
    } catch (e) {
      _error = e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadGoalsFromSupabase();
  }

  Widget buildTermSection(
    String label,
    Color labelColor,
    List<Goal> termGoals,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: labelColor,
            shadows: [
              Shadow(color: labelColor.withOpacity(0.3), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final termGoalIds = termGoals.map((g) => g.id).toList();
              final oldGoalId = termGoalIds[oldIndex];
              final newGoalId = termGoalIds[newIndex];
              final oldIndexInGoals = _goals.indexWhere(
                (g) => g.id == oldGoalId,
              );
              final newIndexInGoals = _goals.indexWhere(
                (g) => g.id == newGoalId,
              );
              final item = _goals.removeAt(oldIndexInGoals);
              _goals.insert(newIndexInGoals, item);
            });
          },
          children: [
            for (final goal in termGoals)
              Dismissible(
                key: ValueKey(goal.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await _deleteGoalFromSupabase(goal);
                  await _loadGoalsFromSupabase();
                  if (mounted) setState(() {});
                },
                child: GestureDetector(
                  onTap: () =>
                      _addOrEditGoal(goal: goal, index: _goals.indexOf(goal)),
                  child: _goalCard(goal),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
      ],
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
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildTermSection(
                          'Short Term Goals',
                          Colors.cyanAccent,
                          _goals
                              .where((g) => g.term == 'Short term 0-6 months')
                              .toList(),
                        ),
                        buildTermSection(
                          'Medium Term Goals',
                          Colors.amber,
                          _goals
                              .where(
                                (g) =>
                                    g.term == 'Medium term 6 months - 2 years',
                              )
                              .toList(),
                        ),
                        buildTermSection(
                          'Long Term Goals',
                          Colors.deepPurpleAccent,
                          _goals
                              .where((g) => g.term == 'Long term 2+ years')
                              .toList(),
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
    print(
      'Rendering goal card: id=${goal.id}, title=${goal.title}, color=${goal.color}, priority=${goal.priority}',
    );
    Color dotColor;
    switch (goal.priority.toLowerCase()) {
      case 'high':
        dotColor = Colors.red;
        break;
      case 'medium':
        dotColor = Colors.yellow[700]!;
        break;
      case 'low':
        dotColor = Colors.green;
        break;
      default:
        dotColor = Colors.yellow;
    }
    final String priorityLabel = (goal.priority.isEmpty)
        ? 'MEDIUM'
        : goal.priority.toUpperCase();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: dotColor.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AutoSizeText(
                    goal.title,
                    style: GoogleFonts.baloo2(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    minFontSize: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    priorityLabel,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: dotColor,
                      fontWeight: FontWeight.w600,
                    ),
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
