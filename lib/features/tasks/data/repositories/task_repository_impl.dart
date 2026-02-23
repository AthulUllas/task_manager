import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:task_manager/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:task_manager/models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;
  final Connectivity connectivity;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<TaskModel> createTask(TaskModel task, String userId) async {
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw Exception('No internet connection. Cannot create task.');
    }
    final newTask = await remoteDataSource.createTask(task, userId);
    final cached = await localDataSource.getCachedTasks();
    await localDataSource.cacheTasks([...cached, newTask]);
    return newTask;
  }

  @override
  Future<List<TaskModel>> getTasks(String userId, {int skip = 0, int limit = 10}) async {
    final connectivityResult = await connectivity.checkConnectivity();
    
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return await localDataSource.getCachedTasks();
    }

    try {
      final remoteTasks = await remoteDataSource.getTasks(userId, skip: skip, limit: limit);
      await localDataSource.cacheTasks(remoteTasks);
      return remoteTasks;
    } catch (e) {
      return await localDataSource.getCachedTasks();
    }
  }

  @override
  Future<TaskModel> getTaskById(String taskId, String userId) async {
    return await remoteDataSource.getTaskById(taskId, userId);
  }

  @override
  Future<TaskModel> updateTask(String taskId, String userId, Map<String, dynamic> updates) async {
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw Exception('No internet connection. Cannot update task.');
    }
    final updatedTask = await remoteDataSource.updateTask(taskId, userId, updates);
    final cached = await localDataSource.getCachedTasks();
    final updatedCache = cached.map((t) => t.id == taskId ? updatedTask : t).toList();
    await localDataSource.cacheTasks(updatedCache);
    return updatedTask;
  }

  @override
  Future<void> deleteTask(String taskId, String userId) async {
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw Exception('No internet connection. Cannot delete task.');
    }
    await remoteDataSource.deleteTask(taskId, userId);
    final cached = await localDataSource.getCachedTasks();
    final updatedCache = cached.where((t) => t.id != taskId).toList();
    await localDataSource.cacheTasks(updatedCache);
  }
}
