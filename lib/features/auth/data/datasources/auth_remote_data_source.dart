import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/models/user_model.dart';
import 'package:task_manager/core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailPassword(String email, String password);
  Future<UserModel> registerWithEmailPassword(
    String email,
    String password,
    String name,
  );
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Login failed: User not found.');
      }

      return await _fetchUserProfile(user.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException('An unexpected error occurred during login.');
    }
  }

  @override
  Future<UserModel> registerWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Registration failed.');
      }

      final userModel = UserModel(
        id: user.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        themeMode: 'system',
      );

      await firestore.collection('users').doc(user.uid).set(userModel.toJson());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed.');
    } catch (e) {
      throw ServerException(
        'An unexpected error occurred during registration.',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to logout.');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      return await _fetchUserProfile(user.uid);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> _fetchUserProfile(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        throw AuthException('User profile not found.');
      }
      return UserModel.fromJson(doc.data()!, documentId: doc.id);
    } catch (e) {
      throw ServerException('Failed to fetch user profile.');
    }
  }
}
