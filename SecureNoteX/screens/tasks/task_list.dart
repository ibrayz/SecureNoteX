import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/task.dart';
import 'task_add.dart';
import 'task_detail.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseHelper.instance.getAllTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _toggleTaskComplete(Task task) async {
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;
    await DatabaseHelper.instance.updateTask(task);
    _loadTasks();
  }

  List<Task> get _activeTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get _completedTasks => _tasks.where((t) => t.isCompleted).toList();

  @override
  Widget build(BuildContext context) {
    final displayTasks = _showCompleted ? _completedTasks : _activeTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('✅ Görevler', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_showCompleted ? Icons.check_box : Icons.check_box_outline_blank),
            onPressed: () => setState(() => _showCompleted = !_showCompleted),
            tooltip: _showCompleted ? 'Aktif Görevler' : 'Tamamlananlar',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskAddScreen()),
              );
              if (result == true) {
                _loadTasks();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Görev eklendi')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(
                  '🔥 Aktif',
                  _activeTasks.length,
                  Colors.orange,
                ),
                _buildStatChip(
                  '✅ Tamamlandı',
                  _completedTasks.length,
                  Colors.green,
                ),
              ],
            ),
          ),
          Expanded(
            child: displayTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showCompleted ? Icons.celebration : Icons.task_alt,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showCompleted ? 'Henüz tamamlanan görev yok' : 'Henüz görev yok',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayTasks.length,
                    onReorder: (oldIndex, newIndex) {
                      // Görevleri sıralama
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      setState(() {
                        final task = displayTasks.removeAt(oldIndex);
                        displayTasks.insert(newIndex, task);
                      });
                    },
                    itemBuilder: (context, index) {
                      final task = displayTasks[index];
                      return _buildTaskCard(task);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color priorityColor;
    switch (task.priority) {
      case 3:
        priorityColor = Colors.red;
        break;
      case 2:
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.blue;
    }

    return Card(
      key: ValueKey(task.id),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: task.isCompleted ? 1 : 3,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
          );
          _loadTasks();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _toggleTaskComplete(task),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted ? Colors.green : priorityColor,
                      width: 2,
                    ),
                    color: task.isCompleted ? Colors.green : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.priorityText,
                  style: TextStyle(
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}