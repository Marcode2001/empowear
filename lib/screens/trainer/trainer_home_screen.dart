// 📄 lib/screens/trainer/trainer_home_screen.dart
// ============================================================
// 🏠 الصفحة الرئيسية للمدرب (Trainer Home Screen)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/course/course_bloc.dart';
import '../../bloc/course/course_event.dart';  // ✅ أضيفي هذا
import '../../bloc/course/course_state.dart';  // ✅ أضيفي هذا
import '../../models/user_model.dart';
import '../../models/course_models.dart';
import 'trainer_chat_list_page.dart';
import 'upload_required_projects_page.dart';
import 'receive_student_projects_page.dart';
import 'trainer_courses_main_page.dart';
import 'trainer_profile_page.dart';

// ============================================================
// 🏠 القسم 1: شاشة التنقل الرئيسية (Bottom Navigation)
// ============================================================

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  int _selectedIndex = 0;
  bool _showChatBadge = true;

  final List<Widget> _screens = [
    const TrainerHomePage(),
    const TrainerChatListPage(),
    const TrainerProfilePage(),
  ];

  final List<String> _titles = ['Home', 'Chats', 'Profile'];

  Widget _buildChatIconWithBadge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.chat_bubble_outline, size: 26),
        if (_showChatBadge)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            setState(() => _showChatBadge = false);
          }
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ============================================================
// 📋 القسم 2: الصفحة الرئيسية (تعرض قائمة الكورسات باستخدام CourseBloc)
// ============================================================

class TrainerHomePage extends StatefulWidget {
  const TrainerHomePage({super.key});

  @override
  State<TrainerHomePage> createState() => _TrainerHomePageState();
}

class _TrainerHomePageState extends State<TrainerHomePage> {
  @override
  void initState() {
    super.initState();
    // ✅ تحميل الكورسات عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // في _HomePageState.initState():
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        // ✅ تأكدي إن الـ userId هو نفسه في كل الصفحات
        context.read<CourseBloc>().add(
          LoadRegisteredCoursesEvent(userId: authState.user.id),  // ← نفس الـ ID
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ الحصول على حالة المصادقة
    final authState = context.watch<AuthBloc>().state;

    // ✅ الحصول على حالة الكورسات
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, courseState) {
        // ✅ استخراج اسم المستخدم
        String userName = 'Trainer';
        if (authState is AuthAuthenticated) {
          userName = authState.user.name;
        }

        // ✅ استخراج الكورسات والإحصائيات من CourseBloc
        List<CourseItem> courses = [];
        int totalCourses = 0;
        int totalStudents = 0;

        // ✅ التحقق من نوع الحالة بشكل صحيح
        if (courseState is RegisteredCoursesLoaded) {
          courses = courseState.registeredCourses;
          totalCourses = courses.length;
          totalStudents = courses.fold(0, (sum, course) => sum + course.studentsCount);
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // 🎴 بطاقة الترحيب (Welcome Card)
              // ============================================================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
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
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ============================================================
              // 📊 بطاقات الإحصائيات (Stats Cards)
              // ============================================================
              Row(
                children: [
                  _buildStatCard(Icons.menu_book, 'Courses', '$totalCourses', Colors.deepPurple),
                  const SizedBox(width: 12),
                  _buildStatCard(Icons.people, 'Students', '$totalStudents', Colors.orange),
                ],
              ),
              const SizedBox(height: 24),

              // ============================================================
              // 🔗 أزرار الإجراءات السريعة (Quick Actions)
              // ============================================================
              Row(
                children: [
                  Expanded(
                    child: _serviceCard(
                      context,
                      'Upload\nProjects',
                      'Add new projects',
                      Icons.upload_file,
                      Colors.blue,
                      const UploadRequiredProjectsPage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _serviceCard(
                      context,
                      'Receive\nProjects',
                      'Grade submissions',
                      Icons.folder_open,
                      Colors.green,
                      const ReceiveStudentProjectsPage(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ============================================================
              // 📚 قسم الكورسات (Courses Section)
              // ============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Courses',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (courses.isNotEmpty)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TrainerCoursesMainPage(),
                        ),
                      ),
                      child: const Text(
                        'See All',
                        style: TextStyle(color: Colors.deepPurple, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // ✅ قائمة الكورسات (من CourseBloc)
              if (courseState is CourseLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (courseState is CourseError)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      courseState.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (courses.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.school_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No courses yet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  ...courses.map((course) => GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrainerCoursesMainPage(
                          selectedCourseId: course.id,
                        ),
                      ),
                    ),
                    child: _buildCourseCard(course),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard(BuildContext context, String title, String sub, IconData icon, Color c, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: c, size: 36),
            const SizedBox(height: 6),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(sub, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseItem course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(course.trainerName, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    const SizedBox(width: 12),
                    Icon(Icons.people_outline, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${course.studentsCount} students', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 11, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(course.totalHours, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    const SizedBox(width: 12),
                    Icon(Icons.video_library, size: 11, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text('${course.sessions.length} sessions', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
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
    );
  }
}