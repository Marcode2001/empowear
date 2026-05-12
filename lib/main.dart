// 📄 lib/main.dart
// ============================================================
// 🚀 نقطة الدخول الرئيسية للتطبيق
// ============================================================

import 'package:empower/screens/admin/admin_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/course/course_bloc.dart';
import 'bloc/project/project_bloc.dart';
import 'bloc/chat/chat_bloc.dart';
import 'bloc/job/job_bloc.dart';

import 'repositories/auth_repository.dart';
import 'repositories/course_repository.dart';
import 'repositories/project_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/job_repository.dart';

import 'screens/auth/login_screen.dart';
import 'screens/trainee/trainee_home_screen.dart';
import 'screens/trainer/trainer_home_screen.dart';

import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()..add(const CheckAuthStatusEvent())),
        BlocProvider(create: (context) => CourseBloc(courseRepository: CourseRepository())),
        BlocProvider(create: (context) => ProjectBloc(projectRepository: ProjectRepository())),
        BlocProvider(create: (context) => ChatBloc(chatRepository: ChatRepository())),
        BlocProvider(create: (_) => JobBloc(jobRepository: JobRepository())),
      ],
      child: MaterialApp(
        title: 'Empower',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        home: const AppInitializer(),
      ),
    );
  }
}

// ============================================================
// 🎯 صفحة التوجيه التلقائي (AppInitializer)
// ============================================================

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.deepPurple),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          print('🎯 [AppInitializer] User type: ${state.user.userType}');
          print('🎯 [AppInitializer] User name: ${state.user.name}');

          // ✅ مدرب
          if (state.user.userType == UserType.trainer) {
            print('🎯 [AppInitializer] 🟢 Going to TrainerHomeScreen');
            return const TrainerHomeScreen();
          }

          // ✅ أدمن
          if (state.user.userType == UserType.admin) {
            print('🎯 [AppInitializer] 🔵 Going to AdminHomeScreen');
            return const AdminHomeScreen();
          }

          // ✅ طالب
          print('🎯 [AppInitializer] 🟡 Going to TraineeHomeScreen');
          return const TraineeHomeScreen();
        }

        print('🎯 [AppInitializer] 🔴 Going to LoginScreen');
        return const LoginScreen();
      },
    );
  }
}