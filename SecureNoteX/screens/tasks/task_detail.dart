import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../db/database_helper.dart';
import '../../models/task.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  Timer? _pomodoroTimer;
  int _pomodoroSeconds = 25 * 60; // 25 dakika
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  void dispose() {
    _pomodoroTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isTimerRunning = true);
    _pomodoroTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_pomodoroSeconds > 0) {
          _pomodoroSeconds--;
        } else {
          _pomodoroTimer?.cancel();
          _isTimerRunning = false;
          _task.pomodoroCount++;
          DatabaseHelper.instance.updateTask(_task);
          _pomodoroSeconds = 25 * 60;
          _showPomodoroCompleteDialog();
        }
      });
    });
  }

  void _pauseTimer() {
    _pomodoroTimer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _resetTimer() {
    _pomodoroTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _pomodoroSeconds = 25 * 60;
    });
  }

  void _showPomodoroCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Pomodoro Tamamlandı!'),
        content: const Text('Harika iş! 5 dakika mola zamanı.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleComplete() async {
    setState(() {
      _task.isCompleted = !_task.isCompleted;
      _task.completedAt = _task.isCompleted ? DateTime.now() : null;
    });
    await DatabaseHelper.instance.updateTask(_task);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_task.isCompleted ? '✅ Görev tamamlandı!' : 'Görev aktif olarak işaretlendi'),
        ),
      );
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: const Text('Bu görevi silmek istediğinizden emin misiniz?'),
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
      await DatabaseHelper.instance.deleteTask(_task.id!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  String get _timerText {
    final minutes = _pomodoroSeconds ~/ 60;
    final seconds = _pomodoroSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (_task.priority) {
      case 3:
        priorityColor = Colors.red;
        break;
      case 2:
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.blue;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: priorityColor,
        title: const Text('Görev Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTask,
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
                  colors: [priorityColor, priorityColor.withOpacity(0.7)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _task.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _task.priorityText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_task.description.isNotEmpty) ...[
                    const Text(
                      'Açıklama',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _task.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_task.dueDate != null) ...[
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Bitiş: ${DateFormat('dd MMMM yyyy').format(_task.dueDate!)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text(
                    '🍅 Pomodoro Timer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: priorityColor.withOpacity(0.1),
                            border: Border.all(color: priorityColor, width: 4),
                          ),
                          child: Center(
                            child: Text(
                              _timerText,
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: priorityColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!_isTimerRunning)
                              ElevatedButton.icon(
                                onPressed: _startTimer,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Başlat'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: _pauseTimer,
                                icon: const Icon(Icons.pause),
                                label: const Text('Duraklat'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _resetTimer,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Sıfırla'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tamamlanan Pomodoro: ${_task.pomodoroCount}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleComplete,
        backgroundColor: _task.isCompleted ? Colors.grey : Colors.green,
        icon: Icon(_task.isCompleted ? Icons.undo : Icons.check),
        label: Text(_task.isCompleted ? 'Aktif Yap' : 'Tamamla'),
      ),
    );
  }
}