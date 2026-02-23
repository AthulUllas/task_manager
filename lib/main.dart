import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:task_manager/features/auth/presentation/pages/login_page.dart';
import 'package:task_manager/features/tasks/presentation/pages/dashboard_page.dart';
import 'package:task_manager/features/tasks/presentation/providers/task_provider.dart';
import 'package:task_manager/features/auth/presentation/providers/auth_provider.dart'
    as app_auth;
import 'package:task_manager/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:task_manager/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:task_manager/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_manager/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:task_manager/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/register_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:task_manager/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final client = http.Client();
  final taskRemoteDataSource = TaskRemoteDataSourceImpl(client: client);
  final taskRepository = TaskRepositoryImpl(
    remoteDataSource: taskRemoteDataSource,
  );

  // Auth Dependencies
  final authRemoteDataSource = AuthRemoteDataSourceImpl(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(repository: taskRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => app_auth.AuthProvider(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            logoutUseCase: logoutUseCase,
            getCurrentUserUseCase: getCurrentUserUseCase,
          )..fetchProfile(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const DashboardPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
