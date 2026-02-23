import 'package:task_manager/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> loginWithEmailPassword(String email, String password);
  Future<UserModel> registerWithEmailPassword(String email, String password, String name);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);
}
