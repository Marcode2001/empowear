import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/course/course_bloc.dart';
import 'bloc/project/project_bloc.dart';
import 'bloc/chat/chat_bloc.dart';
import 'bloc/job/job_bloc.dart';
import 'bloc/previous_student_work/previous_student_work_bloc.dart';
import 'bloc/certificate/certificate_bloc.dart';
import 'repositories/certificate_repository.dart';
import 'repositories/course_repository.dart';
import 'repositories/project_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/job_repository.dart';
import 'repositories/previous_student_work_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/trainee/trainee_home_screen.dart';
import 'screens/trainer/trainer_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
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
        BlocProvider(
          create: (_) => AuthBloc()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (_) => CourseBloc(courseRepository: CourseRepository()),
        ),
        BlocProvider(
          create: (_) => ProjectBloc(projectRepository: ProjectRepository()),
        ),
        BlocProvider(
          create: (_) => PreviousWorkBloc(PreviousStudentWorkRepository()),
        ),
        BlocProvider(create: (_) => ChatBloc(repo: ChatRepository())),
        BlocProvider(create: (_) => JobBloc(jobRepository: JobRepository())),
        BlocProvider(create: (_) => CertificateBloc(CertificateRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Empower',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
        ),
        home: const AppRouter(),
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // ✅ Imperatively navigate and clear the entire stack on logout
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is AuthAuthenticated) {
            final user = state.user;
            if (user.userType == UserType.admin) return const AdminHomeScreen();
            if (user.userType == UserType.trainer)
              return const TrainerHomeScreen();
            return const TraineeHomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
