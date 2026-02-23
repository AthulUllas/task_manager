import 'package:flutter/material.dart';
import 'package:task_manager/models/user_model.dart';
import 'package:task_manager/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/register_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:task_manager/core/errors/exceptions.dart';

class AuthProvider with ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _getCurrentUserUseCase();
    } catch (e) {
      _error = 'Failed to fetch user profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _loginUseCase(email, password);
    } on AuthException catch (e) {
      _error = e.message;
    } on ServerException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred during login.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _registerUseCase(email, password, name);
    } on AuthException catch (e) {
      _error = e.message;
    } on ServerException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred during registration.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _logoutUseCase();
      _user = null;
    } catch (e) {
      _error = 'Failed to logout.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
