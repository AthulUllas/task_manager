import 'package:task_manager/models/user_model.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserModel> call(String email, String password, String name) {
    return repository.registerWithEmailPassword(email, password, name);
  }
}
