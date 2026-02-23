import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:task_manager/models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<List<TaskModel>> getCachedTasks();
  Future<void> clearCache();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box box;

  TaskLocalDataSourceImpl({required this.box});

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final tasksJson = tasks.map((t) => t.toJson()).toList();
    await box.put('cached_tasks', json.encode(tasksJson));
  }

  @override
  Future<List<TaskModel>> getCachedTasks() async {
    final rawData = box.get('cached_tasks');
    if (rawData == null) return [];
    
    final List<dynamic> decoded = json.decode(rawData);
    return decoded.map((jsonMap) => TaskModel.fromJson(jsonMap)).toList();
  }

  @override
  Future<void> clearCache() async {
    await box.delete('cached_tasks');
  }
}
