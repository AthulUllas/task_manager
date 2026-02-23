import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/core/errors/exceptions.dart';
import 'package:task_manager/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:task_manager/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:task_manager/core/providers.dart';

class TaskState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? error;

  TaskState({this.tasks = const [], this.isLoading = false, this.error});

  TaskState copyWith({List<TaskModel>? tasks, bool? isLoading, String? error}) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;

  TaskNotifier({required TaskRepository repository})
    : _repository = repository,
      super(TaskState());

  Future<void> fetchTasks(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _repository.getTasks(userId);
      state = state.copyWith(tasks: tasks, isLoading: false);
    } on ServerException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred while fetching tasks.',
      );
    }
  }

  Future<void> addTask(TaskModel task, String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newTask = await _repository.createTask(task, userId);
      state = state.copyWith(
        tasks: [newTask, ...state.tasks],
        isLoading: false,
      );
    } on ServerException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to add task.');
    }
  }

  Future<void> updateTaskStatus(
    String taskId,
    String userId,
    bool isCompleted,
  ) async {
    final oldTasks = [...state.tasks];
    try {
      // Find the existing task
      final taskToUpdate = state.tasks.firstWhere((t) => t.id == taskId);

      final optimisticTasks = state.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(isCompleted: isCompleted);
        }
        return t;
      }).toList();
      state = state.copyWith(tasks: optimisticTasks);

      final updates = {
        'id': taskId,
        'is_completed': isCompleted,
        'completed': isCompleted,
        'isCompleted': isCompleted,
        'status': isCompleted ? 1 : 0,
        'title': taskToUpdate.title,
        'description': taskToUpdate.description,
        'priority': taskToUpdate.priority,
        'category': taskToUpdate.category,
      };

      final updatedTask = await _repository.updateTask(taskId, userId, updates);

      final syncedTasks = state.tasks.map((t) {
        if (t.id == taskId) {
          return updatedTask;
        }
        return t;
      }).toList();
      state = state.copyWith(tasks: syncedTasks);
    } catch (e) {
      // Revert if failed
      state = state.copyWith(tasks: oldTasks, error: 'Failed to update task.');
    }
  }

  Future<void> deleteTask(String taskId, String userId) async {
    try {
      await _repository.deleteTask(taskId, userId);
      final updatedTasks = state.tasks.where((t) => t.id != taskId).toList();
      state = state.copyWith(tasks: updatedTasks);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete task.');
    }
  }
}

enum TaskFilter { all, pending, completed }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final taskState = ref.watch(taskProvider);

  switch (filter) {
    case TaskFilter.all:
      return taskState.tasks;
    case TaskFilter.pending:
      return taskState.tasks.where((task) => !task.isCompleted).toList();
    case TaskFilter.completed:
      return taskState.tasks.where((task) => task.isCompleted).toList();
  }
});

final _taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(client: ref.watch(httpClientProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    remoteDataSource: ref.watch(_taskRemoteDataSourceProvider),
  );
});

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(repository: ref.watch(taskRepositoryProvider));
});
