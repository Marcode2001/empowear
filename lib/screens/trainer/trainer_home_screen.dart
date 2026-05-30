// 📄 lib/screens/trainer/trainer_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../models/course_models.dart';
import '../../services/api_service.dart';
import 'trainer_chat_page.dart';
import 'receive_student_projects_page.dart';
import 'trainer_profile_page.dart';
import 'trainer_courses_main_page.dart';
import '../auth/login_screen.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TrainerHomePage(),
    TrainerChatPage(),
    const TrainerProfilePage(),
  ];

  final List<String> _titles = ['Home', 'Chats', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _titles[_selectedIndex],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chats',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class TrainerHomePage extends StatefulWidget {
  const TrainerHomePage({super.key});

  @override
  State<TrainerHomePage> createState() => _TrainerHomePageState();
}

class _TrainerHomePageState extends State<TrainerHomePage> {
  List<CourseItem> _courses = [];
  bool _isLoading = true;
  int _totalPendingProjects = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated &&
          authState.user.userType.name == "trainer") {
        _loadTrainerData();
      }
    });
  }

  Future<void> _loadTrainerData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not authenticated';
        });
        return;
      }

      final coursesResponse = await ApiService.get(
        endpoint: 'course/trainer-my-courses/',
        requireAuth: true,
      );

      print(
        '📊 [Trainer] جلب كورسات المدرب - Status: ${coursesResponse['statusCode']}',
      );

      if (!mounted) return;

      if (coursesResponse['success']) {
        final data = coursesResponse['data'];
        final List<dynamic> coursesData = data is List ? data : [];
        final List<CourseItem> fetchedCourses = coursesData
            .map((json) => CourseItem.fromJson(json))
            .toList();
        setState(() {
          _courses = fetchedCourses;
        });
      }

      final submissionsResponse = await ApiService.get(
        endpoint: 'design-submission/trainer-all-submissions/',
        requireAuth: true,
      );

      print(
        '📊 [Trainer] جلب مشاريع الطلاب - Status: ${submissionsResponse['statusCode']}',
      );

      if (!mounted) return;

      if (submissionsResponse['success']) {
        final submissionsData = submissionsResponse['data'];
        final List<dynamic> submissions = submissionsData is List
            ? submissionsData
            : [];

        int pendingCount = 0;
        for (var submission in submissions) {
          final status =
              submission['submission_status']?.toString().toLowerCase() ?? '';
          if (status == 'submitted' || status == 'pending') {
            pendingCount++;
          }
        }

        setState(() {
          _totalPendingProjects = pendingCount;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [Trainer] خطأ في جلب البيانات: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    String userName = 'Trainer';
    if (authState is AuthAuthenticated) {
      userName = authState.user.name;
    }

    return RefreshIndicator(
      onRefresh: _loadTrainerData,
      color: Colors.deepPurple,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                _buildStatCard(
                  Icons.menu_book,
                  'Courses',
                  '${_courses.length}',
                  Colors.deepPurple,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  Icons.pending_actions,
                  'Pending Projects',
                  '$_totalPendingProjects',
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _serviceCard(
              context,
              'Review Student Projects',
              'Grade and evaluate student submissions',
              Icons.folder_open,
              Colors.green,
              const ReceiveStudentProjectsPage(),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Courses',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_courses.isNotEmpty && !_isLoading)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrainerCoursesMainPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTrainerData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_courses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.school_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No courses yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your courses will appear here',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ..._courses.take(3).map((course) => _buildCourseCard(course)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon,
      String label,
      String value,
      Color color,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard(
      BuildContext context,
      String title,
      String sub,
      IconData icon,
      Color c,
      Widget page,
      ) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: c, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: c,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseItem course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TrainerCoursesMainPage(selectedCourseId: course.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.menu_book, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.studentsCount} students',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Level ${course.levelNumber}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
