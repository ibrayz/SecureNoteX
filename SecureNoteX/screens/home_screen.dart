import 'package:flutter/material.dart';
import 'dart:math';
import '../db/database_helper.dart';
import 'notes/note_list.dart';
import 'tasks/task_list.dart';
import 'goals/goal_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _motivationalQuotes = [
    '🚀 Bugün harika şeyler yapacaksın!',
    '💪 Her küçük adım büyük bir yolculuğun parçası',
    '✨ Başarı, küçük çabaların tekrarıdır',
    '🎯 Hedeflerine odaklan, başarı gelecek',
    '🌟 Sen yapabilirsin! İnan ve başar',
    '🔥 Bugün dünden daha iyisin',
    '💎 Potansiyelinin sınırını zorla',
    '🌈 Her yeni gün yeni bir fırsat',
  ];

  String _todayQuote = '';
  int _totalNotes = 0;
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _totalGoals = 0;
  int _maxStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final notes = await db.getAllNotes();
    final tasks = await db.getAllTasks();
    final goals = await db.getAllGoals();

    final completed = tasks.where((t) => t.isCompleted).length;
    final maxStreak = goals.isEmpty ? 0 : goals.map((g) => g.currentStreak).reduce(max);

    setState(() {
      _todayQuote = _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
      _totalNotes = notes.length;
      _totalTasks = tasks.length;
      _completedTasks = completed;
      _totalGoals = goals.length;
      _maxStreak = maxStreak;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'SecureNoteX',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                        child: Text(
                          _todayQuote,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStatsCard(theme),
                    const SizedBox(height: 24),
                    _buildModuleCard(
                      context,
                      title: '📝 Notlar',
                      subtitle: '$_totalNotes not',
                      color: Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NoteListScreen()),
                      ).then((_) => _loadData()),
                    ),
                    const SizedBox(height: 16),
                    _buildModuleCard(
                      context,
                      title: '✅ Görevler',
                      subtitle: '$_completedTasks/$_totalTasks tamamlandı',
                      color: Colors.green,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TaskListScreen()),
                      ).then((_) => _loadData()),
                    ),
                    const SizedBox(height: 16),
                    _buildModuleCard(
                      context,
                      title: '🎯 Hedefler',
                      subtitle: '$_totalGoals hedef • $_maxStreak gün streak',
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GoalListScreen()),
                      ).then((_) => _loadData()),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bugünün Özeti',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('📝', _totalNotes.toString(), 'Not'),
                _buildStatItem('✅', _completedTasks.toString(), 'Tamamlandı'),
                _buildStatItem('🔥', _maxStreak.toString(), 'Max Streak'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}