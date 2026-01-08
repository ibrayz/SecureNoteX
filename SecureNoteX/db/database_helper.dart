import 'package:hive/hive.dart';
import '../models/note.dart';
import '../models/task.dart';
import '../models/goal.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  // Notes CRUD
  Future<int> createNote(Note note) async {
    try {
      final box = Hive.box('notes');
      final keys = box.keys.cast<int>().toList();
      final id = keys.isEmpty ? 1 : keys.reduce((a, b) => a > b ? a : b) + 1;
      note.id = id;
      await box.put(id, note.toMap());
      print('✅ Not kaydedildi: $id');
      return id;
    } catch (e) {
      print('❌ Hata: $e');
      rethrow;
    }
  }

  Future<List<Note>> getAllNotes() async {
    final box = Hive.box('notes');
    return box.values
        .map((item) => Note.fromMap(Map<String, dynamic>.from(item)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<int> updateNote(Note note) async {
    final box = Hive.box('notes');
    await box.put(note.id, note.toMap());
    return 1;
  }

  Future<int> deleteNote(int id) async {
    final box = Hive.box('notes');
    await box.delete(id);
    return 1;
  }

  // Tasks CRUD
  Future<int> createTask(Task task) async {
    try {
      final box = Hive.box('tasks');
      final keys = box.keys.cast<int>().toList();
      final id = keys.isEmpty ? 1 : keys.reduce((a, b) => a > b ? a : b) + 1;
      task.id = id;
      await box.put(id, task.toMap());
      print('✅ Görev kaydedildi: $id');
      return id;
    } catch (e) {
      print('❌ Hata: $e');
      rethrow;
    }
  }

  Future<List<Task>> getAllTasks() async {
    final box = Hive.box('tasks');
    final tasks = box.values
        .map((item) => Task.fromMap(Map<String, dynamic>.from(item)))
        .toList();
    
    // Priority ve tarih sıralaması
    tasks.sort((a, b) {
      final priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return tasks;
  }

  Future<int> updateTask(Task task) async {
    final box = Hive.box('tasks');
    await box.put(task.id, task.toMap());
    return 1;
  }

  Future<int> deleteTask(int id) async {
    final box = Hive.box('tasks');
    await box.delete(id);
    return 1;
  }

  // Goals CRUD
  Future<int> createGoal(Goal goal) async {
    try {
      final box = Hive.box('goals');
      final keys = box.keys.cast<int>().toList();
      final id = keys.isEmpty ? 1 : keys.reduce((a, b) => a > b ? a : b) + 1;
      goal.id = id;
      await box.put(id, goal.toMap());
      print('✅ Hedef kaydedildi: $id');
      return id;
    } catch (e) {
      print('❌ Hata: $e');
      rethrow;
    }
  }

  Future<List<Goal>> getAllGoals() async {
    final box = Hive.box('goals');
    return box.values
        .map((item) => Goal.fromMap(Map<String, dynamic>.from(item)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<int> updateGoal(Goal goal) async {
    final box = Hive.box('goals');
    await box.put(goal.id, goal.toMap());
    return 1;
  }

  Future<int> deleteGoal(int id) async {
    final box = Hive.box('goals');
    await box.delete(id);
    return 1;
  }

  Future<void> close() async {
    await Hive.close();
  }
}