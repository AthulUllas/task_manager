import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/core/errors/exceptions.dart';

abstract class TaskRemoteDataSource {
  Future<TaskModel> createTask(TaskModel task, String userId);
  Future<List<TaskModel>> getTasks(String userId, {int skip = 0, int limit = 10});
  Future<TaskModel> getTaskById(String taskId, String userId);
  Future<TaskModel> updateTask(String taskId, String userId, Map<String, dynamic> updates);
  Future<void> deleteTask(String taskId, String userId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'https://taskmanager.uat-lplusltd.com';

  TaskRemoteDataSourceImpl({required this.client});

  @override
  Future<TaskModel> createTask(TaskModel task, String userId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/tasks/?user_id=$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse['status'] == 'success') {
        return TaskModel.fromJson(decodedResponse['data']);
      } else {
        throw ServerException(decodedResponse['message'] ?? 'Failed to create task');
      }
    } else {
      throw ServerException('Failed to connect to server: ${response.statusCode}');
    }
  }

  @override
  Future<List<TaskModel>> getTasks(String userId, {int skip = 0, int limit = 10}) async {
    final response = await client.get(
      Uri.parse('$baseUrl/tasks/?user_id=$userId&skip=$skip&limit=$limit'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse['status'] == 'success') {
        final List<dynamic> data = decodedResponse['data'];
        return data.map((taskJson) => TaskModel.fromJson(taskJson)).toList();
      } else {
        throw ServerException(decodedResponse['message'] ?? 'Failed to retrieve tasks');
      }
    } else {
      throw ServerException('Failed to connect to server: ${response.statusCode}');
    }
  }

  @override
  Future<TaskModel> getTaskById(String taskId, String userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/tasks/$taskId?user_id=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse['status'] == 'success') {
        return TaskModel.fromJson(decodedResponse['data'], taskId: taskId);
      } else {
        throw ServerException(decodedResponse['message'] ?? 'Failed to retrieve task');
      }
    } else {
      throw ServerException('Failed to connect to server: ${response.statusCode}');
    }
  }

  @override
  Future<TaskModel> updateTask(String taskId, String userId, Map<String, dynamic> updates) async {
    final response = await client.put(
      Uri.parse('$baseUrl/tasks/$taskId?user_id=$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse['status'] == 'success') {
        return TaskModel.fromJson(decodedResponse['data'], taskId: taskId);
      } else {
        throw ServerException(decodedResponse['message'] ?? 'Failed to update task');
      }
    } else {
      throw ServerException('Failed to connect to server: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteTask(String taskId, String userId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/tasks/$taskId?user_id=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse['status'] != 'success') {
        throw ServerException(decodedResponse['message'] ?? 'Failed to delete task');
      }
    } else {
      throw ServerException('Failed to connect to server: ${response.statusCode}');
    }
  }
}
