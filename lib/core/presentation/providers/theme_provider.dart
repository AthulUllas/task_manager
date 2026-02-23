import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/features/auth/presentation/providers/auth_provider.dart';

final themeProvider = Provider<ThemeMode>((ref) {
  final authState = ref.watch(authProvider);
  final themeMode = authState.user?.themeMode ?? 'dark';
  
  switch (themeMode.toLowerCase()) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.dark;
  }
});
