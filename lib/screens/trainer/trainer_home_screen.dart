// 📄 lib/screens/trainer/trainer_home_screen.dart
// ============================================================
// 🏠 Trainer Home Screen (English Version)
// ✅ Chat badge management included
// ✅ Bottom Nav: Home • Chats • Profile (No Courses tab)
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/course_models.dart';
import 'trainer_course_page.dart';
import 'trainer_courses_detail_page.dart';
import 'trainer_chat_list_page.dart';
import 'upload_required_projects_page.dart';
import 'receive_student_projects_page.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});
  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  int _selectedIndex = 0;

  // ✅ Control badge visibility from home screen
  bool _showChatBadge = true;

  final List<Widget> _screens = [
    const TrainerHomePage(),
    const TrainerChatListPage(),  // ✅ Chat list page
    const Center(child: Text('Profile', style: TextStyle(fontSize: 24))),
  ];

  final List<String> _titles = ['Home', 'Chats', 'Profile'];

  // ✅ Build chat icon with optional red badge
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
        title: Text(_titles[_selectedIndex], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]))),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          // ✅ Hide badge when entering Chats tab
          if (index == 1) {
            setState(() => _showChatBadge = false);
          }
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: _buildChatIconWithBadge(), label: 'Chats'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ============================================================
// 📋 Trainer Home Page (English)
// ============================================================
class TrainerHomePage extends StatelessWidget {
  const TrainerHomePage({super.key});

  List<CourseItem> _getTrainerCourses() {
    return [
      CourseItem(
        id: 'c1', title: 'Fashion Illustration', description: 'Learn fashion illustration basics',
        levelNumber: 1, price: 'Free', totalHours: '12h', trainerName: 'Emma Watson',
        sessions: [
          Session(id: 's1', title: 'Proportions & Basics', description: 'Body proportions and basic poses', curriculum: [
            Lesson(id: 'l1', title: 'Understanding Body Proportions', duration: '20 min', type: 'video', url: ''),
          ]),
        ],
      ),
      CourseItem(
        id: 'c2', title: 'Digital Fashion Design', description: 'Digital design techniques',
        levelNumber: 2, price: 'Free', totalHours: '10h', trainerName: 'Sarah Johnson',
        sessions: [
          Session(id: 's2', title: 'Digital Tools', description: 'Introduction to digital tools', curriculum: [
            Lesson(id: 'l2', title: 'Procreate Setup', duration: '18 min', type: 'video', url: ''),
          ]),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final trainerCourses = _getTrainerCourses();
    final totalCourses = trainerCourses.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 🎴 Welcome Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Welcome 👋', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(user?.name ?? 'Trainer', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ]),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 45)),
          ]),
        ),
        const SizedBox(height: 24),

        // 📊 Stats Cards
        Row(children: [
          _buildStatCard(Icons.menu_book, 'Courses', '$totalCourses', Colors.deepPurple),
          const SizedBox(width: 12),
          _buildStatCard(Icons.people, 'Students', '150', Colors.orange),
        ]),
        const SizedBox(height: 24),

        // 🔗 Quick Actions
        Row(children: [
          Expanded(child: _serviceCard(context, 'Upload\nProjects', 'Add new projects', Icons.upload_file, Colors.blue, const UploadRequiredProjectsPage())),
          const SizedBox(width: 12),
          Expanded(child: _serviceCard(context, 'Receive\nProjects', 'Grade submissions', Icons.folder_open, Colors.green, const ReceiveStudentProjectsPage())),
        ]),
        const SizedBox(height: 24),

        // 📚 Courses Section
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('My Assigned Courses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrainerCoursePage(courses: trainerCourses))),
            child: const Text('See All', style: TextStyle(color: Colors.deepPurple, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 12),

        // ✅ Course Cards
        ...trainerCourses.map((course) => GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrainerCoursesDetailPage(course: course))),
          child: _buildCourseCard(course),
        )),
      ]),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)]), child: Column(children: [Icon(icon, color: color, size: 28), const SizedBox(height: 6), Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)), Text(label, style: TextStyle(fontSize: 12, color: Colors.grey))])));
  }

  Widget _serviceCard(BuildContext context, String title, String sub, IconData icon, Color c, Widget page) {
    return GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)), child: Container(height: 130, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withOpacity(0.3))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: c, size: 36), const SizedBox(height: 6), Text(title, textAlign: TextAlign.center, style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(sub, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 10))])));
  }

  Widget _buildCourseCard(CourseItem course) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)]), child: Row(children: [
      Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.menu_book, color: Colors.deepPurple, size: 28))),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(course.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Row(children: [const Icon(Icons.person_outline, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(course.trainerName, style: TextStyle(fontSize: 12, color: Colors.grey[600])), const SizedBox(width: 12), const Icon(Icons.access_time, size: 12, color: Colors.grey), const SizedBox(width: 4), Text(course.totalHours, style: TextStyle(fontSize: 11, color: Colors.grey[500]))]), const SizedBox(height: 4), Text('${course.sessions.length} Sessions • Level ${course.levelNumber}', style: TextStyle(fontSize: 11, color: Colors.grey[500]))])),
      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    ]));
  }
}