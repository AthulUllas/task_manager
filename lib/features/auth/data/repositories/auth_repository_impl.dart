import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_manager/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:task_manager/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserModel> loginWithEmailPassword(String email, String password) async {
    return await remoteDataSource.loginWithEmailPassword(email, password);
  }

  @override
  Future<UserModel> registerWithEmailPassword(String email, String password, String name) async {
    return await remoteDataSource.registerWithEmailPassword(email, password, name);
  }

  @override
  Future<void> logout() async {
    return await remoteDataSource.logout();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    return await remoteDataSource.updateUserProfile(uid, data);
  }
}
