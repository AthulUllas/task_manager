import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/presentation/widgets/cust_button.dart';
import 'package:task_manager/core/presentation/widgets/cust_text_field.dart';
import 'package:task_manager/features/auth/presentation/providers/auth_provider.dart';
import 'package:task_manager/core/presentation/widgets/glass_container.dart';
import 'package:task_manager/features/auth/presentation/pages/login_page.dart';
import 'package:task_manager/core/utils/snackbar_utils.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        final user = ref.read(authProvider).user;
        _nameController.text = user?.name ?? '';
      }
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
        );

    if (!mounted) return;

    final state = ref.read(authProvider);

    if (state.error != null) {
      TaskSnackbar.showError(
        context,
        'UPDATE FAILED',
        state.error!,
      );
    } else {
      setState(() => _isEditing = false);
      TaskSnackbar.showSuccess(
        context,
        'PROFILE UPDATED',
        'Your profile changes have been saved! ✨',
      );
    }
  }

  void _updateTheme(bool isDark) {
    ref.read(authProvider.notifier).updateProfile(
          themeMode: isDark ? 'dark' : 'light',
        );
  }

  void _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final user = state.user;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF1F1B24),
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassContainer(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Display Name',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _isEditing
                              ? CustTextField(
                                  controller: _nameController,
                                  hintText: 'Your name',
                                  prefixIcon: Icons.badge_outlined,
                                  validator: (val) => val == null || val.isEmpty
                                      ? 'Name is required'
                                      : null,
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    user.name,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dark Mode',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.white 
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Currently ${user.themeMode.toUpperCase()}',
                                    style: TextStyle(
                                      color: (Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.white 
                                          : Colors.black).withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: user.themeMode == 'dark',
                                activeColor: const Color(0xFFBB86FC),
                                onChanged: _updateTheme,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _isEditing
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: state.isLoading ? null : _toggleEdit,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white24),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'CANCEL',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustButton(
                                text: 'SAVE',
                                onPressed: state.isLoading
                                    ? null
                                    : _updateProfile,
                                isLoading: state.isLoading,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            CustButton(
                              text: 'EDIT PROFILE',
                              onPressed: _toggleEdit,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _logout,
                              child: const Text(
                                'LOGOUT',
                                style: TextStyle(
                                  color: Color(0xFFE94057),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
    );
  }
}
