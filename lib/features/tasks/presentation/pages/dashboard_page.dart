import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/core/presentation/widgets/glass_container.dart';
import 'package:task_manager/features/tasks/presentation/providers/task_provider.dart';
import 'package:task_manager/features/auth/presentation/providers/auth_provider.dart'
    as auth;
import 'package:task_manager/models/task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<TaskProvider>().fetchTasks(user.uid);
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
    return Consumer<auth.AuthProvider>(
      builder: (context, provider, child) {
        final name = provider.user?.name ?? 'User';
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
            const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF1F1B24),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final total = provider.tasks.length;
        final completed = provider.tasks.where((t) => t.isCompleted).length;
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
      },
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

  Widget _buildTaskList() {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.tasks.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFBB86FC)),
          );
        }
        if (provider.error != null && provider.tasks.isEmpty) {
          return Center(
            child: Text(
              'L error: ${provider.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        if (provider.tasks.isEmpty) {
          return const Center(
            child: Text(
              'No tasks yet.',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) await provider.fetchTasks(user.uid);
          },
          child: ListView.builder(
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              return _buildTaskItem(task);
            },
          ),
        );
      },
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  context.read<TaskProvider>().updateTaskStatus(
                    task.id,
                    user.uid,
                    !task.isCompleted,
                  );
                }
              },
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
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                  const SizedBox(height: 4),
                  Text(
                    task.category,
                    style: TextStyle(
                      color: _getCategoryColor(task.category),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white38),
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null)
                  context.read<TaskProvider>().deleteTask(task.id, user.uid);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'personal':
        return const Color(0xFFBB86FC);
      case 'work':
        return const Color(0xFF03DAC6);
      case 'shopping':
        return const Color(0xFFFFB74D);
      default:
        return Colors.blueAccent;
    }
  }

  void _showAddTaskSheet(BuildContext context) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController(text: 'Personal');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: 'Personal',
                  dropdownColor: const Color(0xFF1F1B24),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  items: ['Personal', 'Work', 'Shopping', 'Health']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => categoryController.text = v ?? 'Personal',
                ),
                const SizedBox(height: 30),
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
                            priority: 'Medium',
                            category: categoryController.text,
                            dueDate: DateTime.now(),
                            createdDate: DateTime.now(),
                          );
                          context.read<TaskProvider>().addTask(task, user.uid);
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
              ],
            ),
          ),
        );
      },
    );
  }
}
