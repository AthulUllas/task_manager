import 'package:task_manager/models/task_model.dart';

abstract class TaskRepository {
  Future<TaskModel> createTask(TaskModel task, String userId);
  Future<List<TaskModel>> getTasks(String userId, {int skip = 0, int limit = 10});
  Future<TaskModel> getTaskById(String taskId, String userId);
  Future<TaskModel> updateTask(String taskId, String userId, Map<String, dynamic> updates);
  Future<void> deleteTask(String taskId, String userId);
}
