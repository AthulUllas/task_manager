import 'package:flutter/material.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/core/errors/exceptions.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository repository;

  TaskProvider({required this.repository});

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await repository.getTasks(userId);
    } on ServerException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred while fetching tasks.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(TaskModel task, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newTask = await repository.createTask(task, userId);
      _tasks.insert(0, newTask);
    } on ServerException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to add task.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTaskStatus(String taskId, String userId, bool isCompleted) async {
    try {
      final updatedTask = await repository.updateTask(taskId, userId, {'is_completed': isCompleted});
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update task.';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId, String userId) async {
    try {
      await repository.deleteTask(taskId, userId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete task.';
      notifyListeners();
    }
  }
}
