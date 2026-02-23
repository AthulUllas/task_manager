import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:task_manager/models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TaskModel> createTask(TaskModel task, String userId) async {
    return await remoteDataSource.createTask(task, userId);
  }

  @override
  Future<List<TaskModel>> getTasks(String userId, {int skip = 0, int limit = 10}) async {
    return await remoteDataSource.getTasks(userId, skip: skip, limit: limit);
  }

  @override
  Future<TaskModel> getTaskById(String taskId, String userId) async {
    return await remoteDataSource.getTaskById(taskId, userId);
  }

  @override
  Future<TaskModel> updateTask(String taskId, String userId, Map<String, dynamic> updates) async {
    return await remoteDataSource.updateTask(taskId, userId, updates);
  }

  @override
  Future<void> deleteTask(String taskId, String userId) async {
    return await remoteDataSource.deleteTask(taskId, userId);
  }
}
