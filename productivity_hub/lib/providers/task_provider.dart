import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_task.dart';

class TaskProvider extends ChangeNotifier {
  static const _tasksKey = 'tasks_data';

  TaskProvider() {
    _loadTasks();
  }

  final List<TodoTask> _tasks = [];

  List<TodoTask> get tasks => List.unmodifiable(_tasks);
  int get completedCount => _tasks.where((task) => task.isCompleted).length;
  int get pendingCount => _tasks.where((task) => !task.isCompleted).length;
  int get overdueCount => _tasks.where((task) => task.isOverdue).length;

  double get completionRatio {
    if (_tasks.isEmpty) {
      return 0;
    }
    return completedCount / _tasks.length;
  }

  Future<void> addTask(
    String title,
    TaskPriority priority, {
    DateTime? dueDate,
  }) async {
    final task = TodoTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      priority: priority,
      dueDate: dueDate,
    );
    _tasks.insert(0, task);
    notifyListeners();
    await _saveTasks();
  }

  Future<void> updateTask({
    required String id,
    required String title,
    required TaskPriority priority,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }

    _tasks[index] = _tasks[index].copyWith(
      title: title,
      priority: priority,
      dueDate: dueDate,
      clearDueDate: clearDueDate,
    );
    notifyListeners();
    await _saveTasks();
  }

  Future<void> toggleTask(String id, bool value) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }

    _tasks[index] = _tasks[index].copyWith(isCompleted: value);
    notifyListeners();
    await _saveTasks();
  }

  Future<void> removeTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    await _saveTasks();
  }

  Future<void> restoreTask(TodoTask task) async {
    _tasks.insert(0, task);
    notifyListeners();
    await _saveTasks();
  }

  Future<void> clearCompleted() async {
    _tasks.removeWhere((task) => task.isCompleted);
    notifyListeners();
    await _saveTasks();
  }

  Future<void> markAllAsCompleted() async {
    for (var index = 0; index < _tasks.length; index++) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: true);
    }
    notifyListeners();
    await _saveTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_tasksKey);
    if (encoded == null || encoded.isEmpty) {
      return;
    }

    final rawList = jsonDecode(encoded) as List<dynamic>;
    _tasks
      ..clear()
      ..addAll(
        rawList.map(
          (item) => TodoTask.fromMap(item as Map<String, dynamic>),
        ),
      );
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = _tasks.map((task) => task.toMap()).toList();
    await prefs.setString(_tasksKey, jsonEncode(rawList));
  }
}
