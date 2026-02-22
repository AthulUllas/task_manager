import 'package:task_manager/models/user_model.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserModel?> call() {
    return repository.getCurrentUser();
  }
}
