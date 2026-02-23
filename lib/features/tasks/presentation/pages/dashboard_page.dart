import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/presentation/widgets/glass_container.dart';
import 'package:task_manager/features/tasks/presentation/providers/task_provider.dart';
import 'package:task_manager/features/auth/presentation/providers/auth_provider.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/features/auth/presentation/pages/profile_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        ref.read(taskProvider.notifier).fetchTasks(user.uid);
        ref.read(authProvider.notifier).fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildStatsRow(),
              const SizedBox(height: 30),
              _buildFilterChips(),
              const SizedBox(height: 15),
              _buildSortChips(),
              const SizedBox(height: 30),
              const Text(
                'YOUR TASKS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(child: _buildTaskList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: const Color(0xFFBB86FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

  Widget _buildHeader() {
    final authState = ref.watch(authProvider);
    final name = authState.user?.name ?? 'User';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${name.split(' ').first}!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
          child: const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFF1F1B24),
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final state = ref.watch(taskProvider);
    final total = state.tasks.length;
    final completed = state.tasks.where((t) => t.isCompleted).length;
    return Row(
      children: [
        _buildStatCard(
          'Active',
          '${total - completed}',
          const Color(0xFF03DAC6),
        ),
        const SizedBox(width: 15),
        _buildStatCard('Done', '$completed', const Color(0xFFBB86FC)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final activeFilter = ref.watch(taskFilterProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TaskFilter.values.map((filter) {
          final isSelected = activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: FilterChip(
              label: Text(
                filter.name.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                ref.read(taskFilterProvider.notifier).state = filter;
              },
              backgroundColor: const Color(0xFF1F1B24),
              selectedColor: const Color(0xFFBB86FC),
              checkmarkColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.white12,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortChips() {
    final activeSort = ref.watch(taskSortProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Text(
            'SORT BY: ',
            style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          ...TaskSort.values.map((sort) {
            final isSelected = activeSort == sort;
            String label = '';
            switch (sort) {
              case TaskSort.dueDate: label = 'DUE DATE'; break;
              case TaskSort.priority: label = 'PRIORITY'; break;
              case TaskSort.createdDate: label = 'CREATED'; break;
            }
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(taskSortProvider.notifier).state = sort;
                  }
                },
                backgroundColor: Colors.transparent,
                selectedColor: const Color(0xFF03DAC6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: isSelected ? Colors.transparent : Colors.white10),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final filteredTasks = ref.watch(filteredTasksProvider);
    final state = ref.watch(taskProvider);
    if (state.isLoading && state.tasks.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFBB86FC)),
      );
    }
    if (state.error != null && state.tasks.isEmpty) {
      return Center(
        child: Text(
          'L error: ${state.error}',
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }
    if (state.tasks.isEmpty) {
      return const Center(
        child: Text('No tasks yet.', style: TextStyle(color: Colors.white38)),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await ref.read(taskProvider.notifier).fetchTasks(user.uid);
        }
      },
      child: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return _buildTaskItem(task);
        },
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    Color priorityColor = Colors.white54;
    switch (task.priority.toLowerCase()) {
      case 'urgent': priorityColor = Colors.redAccent; break;
      case 'high': priorityColor = Colors.orangeAccent; break;
      case 'medium': priorityColor = Colors.blueAccent; break;
      case 'low': priorityColor = Colors.greenAccent; break;
    }

    return Container(
      key: ValueKey(task.id),
      margin: const EdgeInsets.only(bottom: 15),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  ref.read(taskProvider.notifier).updateTaskStatus(
                        task.id,
                        user.uid,
                        !task.isCompleted,
                      );
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? const Color(0xFF03DAC6)
                          : Colors.white24,
                      width: 2,
                    ),
                    color: task.isCompleted
                        ? const Color(0xFF03DAC6).withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Color(0xFF03DAC6),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: Colors.white54,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: priorityColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          task.priority.toUpperCase(),
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.category_outlined, size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        task.category,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(width: 15),
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  ref.read(taskProvider.notifier).deleteTask(task.id, user.uid);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController(text: 'Personal');
    String selectedPriority = 'Medium';
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF1F1B24),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEW MISSION',
                      style: TextStyle(
                        color: Color(0xFFBB86FC),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      decoration: InputDecoration(
                        hintText: 'Task Title...',
                        hintStyle: const TextStyle(color: Colors.white24),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFBB86FC)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PRIORITY',
                                  style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                              DropdownButton<String>(
                                value: selectedPriority,
                                dropdownColor: const Color(0xFF1F1B24),
                                isExpanded: true,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                underline: Container(height: 1, color: Colors.white12),
                                items: ['Low', 'Medium', 'High', 'Urgent'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setModalState(() {
                                    selectedPriority = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('DUE DATE',
                                  style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2101),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Color(0xFFBB86FC),
                                            onPrimary: Colors.black,
                                            surface: Color(0xFF1F1B24),
                                            onSurface: Colors.white,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setModalState(() => selectedDate = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.white12)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                                      const Icon(Icons.calendar_today, size: 16, color: Colors.white38),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Text('CATEGORY',
                        style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: categoryController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Work, Personal, Gym...',
                        hintStyle: TextStyle(color: Colors.white24),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFBB86FC)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              final task = TaskModel(
                                id: '',
                                userId: user.uid,
                                title: titleController.text,
                                description: '',
                                priority: selectedPriority,
                                category: categoryController.text,
                                dueDate: selectedDate,
                                createdDate: DateTime.now(),
                              );
                              ref.read(taskProvider.notifier).addTask(task, user.uid);
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBB86FC),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'IGNITE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
