import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<void> call(String uid, Map<String, dynamic> data) {
    return repository.updateUserProfile(uid, data);
  }
}
