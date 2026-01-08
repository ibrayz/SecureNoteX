import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/goal.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late Goal _goal;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
  }

  Future<void> _completeGoal() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (!_goal.completedDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day)) {
      setState(() {
        _goal.completedDates.add(today);
        _goal.currentCount++;
        _goal.lastCompletedAt = now;
      });

      await DatabaseHelper.instance.updateGoal(_goal);

      if (mounted) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hedefinizi tamamladınız!'),
            const SizedBox(height: 16),
            Text(
              '🔥 ${_goal.currentStreak} gün streak!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Harika!'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hedefi Sil'),
        content: const Text('Bu hedefi silmek istediğinizden emin misiniz? Tüm ilerleme kaybedilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteGoal(_goal.id!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    String typeEmoji;
    switch (_goal.type) {
      case 'daily':
        typeColor = Colors.orange;
        typeEmoji = '☀️';
        break;
      case 'weekly':
        typeColor = Colors.blue;
        typeEmoji = '📅';
        break;
      case 'monthly':
        typeColor = Colors.purple;
        typeEmoji = '📆';
        break;
      default:
        typeColor = Colors.grey;
        typeEmoji = '📌';
    }

    final progress = _goal.currentCount / _goal.targetCount;
    final isCompletedToday = _goal.isCompletedToday();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: typeColor,
        title: const Text('Hedef Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteGoal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [typeColor, typeColor.withOpacity(0.7)],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    typeEmoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _goal.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_goal.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _goal.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('🔥', '${_goal.currentStreak}', 'Streak', typeColor),
                      _buildStatCard('📊', '${_goal.currentCount}', 'Tamamlanan', typeColor),
                      _buildStatCard('🎯', '${_goal.targetCount}', 'Hedef', typeColor),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'İlerleme',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      Text(
                        '${_goal.currentCount}/${_goal.targetCount}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 16,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(typeColor),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Son 30 Gün',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildHeatMap(typeColor),
                  if (isCompletedToday) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 32),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Bugün tamamlandı! Harika iş! 🎉',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isCompletedToday
          ? null
          : FloatingActionButton.extended(
              onPressed: _completeGoal,
              backgroundColor: typeColor,
              icon: const Icon(Icons.check),
              label: const Text('Bugün Tamamla'),
            ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
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
      ),
    );
  }

  Widget _buildHeatMap(Color color) {
    final now = DateTime.now();
    final days = List.generate(30, (index) {
      return now.subtract(Duration(days: 29 - index));
    });

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days.map((day) {
        final isCompleted = _goal.completedDates.any((date) =>
            date.year == day.year && date.month == day.month && date.day == day.day);

        return Tooltip(
          message: '${day.day}/${day.month}',
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: isCompleted ? Colors.white : Colors.grey[600],
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}