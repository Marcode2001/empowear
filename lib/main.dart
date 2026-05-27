// 📄 lib/main.dart
// ============================================================
//  نقطة الدخول الرئيسية للتطبيق
// ============================================================

import 'package:empower/screens/admin/admin_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/chat_seeder.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/course/course_bloc.dart';
import 'bloc/project/project_bloc.dart';
import 'bloc/chat/chat_bloc.dart';
import 'bloc/job/job_bloc.dart';
import 'bloc/previous_student_work/previous_student_work_bloc.dart';


import 'repositories/auth_repository.dart';
import 'repositories/course_repository.dart';
import 'repositories/project_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/job_repository.dart';
import 'repositories/previous_student_work_repository.dart';

import 'screens/auth/login_screen.dart';
import 'screens/trainee/trainee_home_screen.dart';
import 'screens/trainer/trainer_home_screen.dart';



import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  // ✅ أضف هذا السطر - لتشغيل الـ Seeder مرة واحدة فقط
  // بعد أن تعمل المحادثات، يمكنك التعليق على هذا السطر أو حذفه
  //await ChatSeeder.runAll();  // 👈 أضف هذا السطر
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
        BlocProvider(
          create: (_) => PreviousWorkBloc(
            PreviousStudentWorkRepository(),
          ),
        ),
        BlocProvider(create: (context) => ChatBloc(repo: ChatRepository())),
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
        // ✅ إضافة routes لحل مشكلة "/login"
        initialRoute: '/',
        routes: {
          '/': (context) => const AppInitializer(),
          '/login': (context) => const LoginScreen(),
        },
        // ✅ بديل: استخدام onGenerateRoute في حالة عدم وجود route
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        },
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.read<ChatBloc>().add(const ResetChatEvent());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is AuthAuthenticated) {
            if (state.user.userType == UserType.trainer) {
              return const TrainerHomeScreen();
            }

            if (state.user.userType == UserType.admin) {
              return const AdminHomeScreen();
            }

            return const TraineeHomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}