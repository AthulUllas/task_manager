import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:task_manager/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:task_manager/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:task_manager/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/core/errors/exceptions.dart';
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
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
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
      state = state.copyWith(tasks: optimisticTasks, error: null);

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
      // Revert if failed and show specific error
      state = state.copyWith(
        tasks: oldTasks,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> deleteTask(String taskId, String userId) async {
    try {
      await _repository.deleteTask(taskId, userId);
      final updatedTasks = state.tasks.where((t) => t.id != taskId).toList();
      state = state.copyWith(tasks: updatedTasks, error: null);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

enum TaskFilter { all, pending, completed }

enum TaskSort { dueDate, priority, createdDate }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);
final taskSortProvider = StateProvider<TaskSort>((ref) => TaskSort.createdDate);

int _getPriorityValue(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent':
      return 3;
    case 'high':
      return 2;
    case 'medium':
      return 1;
    case 'low':
      return 0;
    default:
      return 1;
  }
}

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final sort = ref.watch(taskSortProvider);
  final taskState = ref.watch(taskProvider);

  List<TaskModel> filtered;
  switch (filter) {
    case TaskFilter.all:
      filtered = [...taskState.tasks];
      break;
    case TaskFilter.pending:
      filtered = taskState.tasks.where((task) => !task.isCompleted).toList();
      break;
    case TaskFilter.completed:
      filtered = taskState.tasks.where((task) => task.isCompleted).toList();
      break;
  }

  switch (sort) {
    case TaskSort.dueDate:
      filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      break;
    case TaskSort.priority:
      filtered.sort(
        (a, b) => _getPriorityValue(
          b.priority,
        ).compareTo(_getPriorityValue(a.priority)),
      );
      break;
    case TaskSort.createdDate:
      filtered.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      break;
  }

  return filtered;
});

final _taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(client: ref.watch(httpClientProvider));
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) {
  return ref.watch(connectivityProvider).onConnectivityChanged;
});

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSourceImpl(box: Hive.box('tasks_box'));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    remoteDataSource: ref.watch(_taskRemoteDataSourceProvider),
    localDataSource: ref.watch(taskLocalDataSourceProvider),
    connectivity: ref.watch(connectivityProvider),
  );
});

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(repository: ref.watch(taskRepositoryProvider));
});
