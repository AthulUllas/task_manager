import 'package:task_manager/models/user_model.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserModel> call(String email, String password) {
    return repository.loginWithEmailPassword(email, password);
  }
}
