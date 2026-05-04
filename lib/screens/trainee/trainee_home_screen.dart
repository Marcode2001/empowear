import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/course_models.dart';
import 'my_courses_page.dart';
import 'job_opportunities_page.dart';
import 'ai_tools.dart';
import 'chat_page.dart';
import 'profile_page.dart';
import 'students_projects_page.dart';
import 'uploaded_projects_page.dart';
import 'register_courses_page.dart';

// ==================== الكلاس الرئيسي للشاشة (TraineeHomeScreen) ====================
class TraineeHomeScreen extends StatefulWidget {
  const TraineeHomeScreen({super.key});

  @override
  State<TraineeHomeScreen> createState() => _TraineeHomeScreenState();
}

class _TraineeHomeScreenState extends State<TraineeHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),      // الصفحة الرئيسية
    const AiToolsPage(),   // صفحة أدوات الذكاء الاصطناعي
    const ChatsListPage(), // صفحة الدردشات
    const ProfilePage(),   // صفحة الملف الشخصي
  ];

  final List<String> _titles = [
    'Home',
    'AI Tools',
    'Chats',
    'Profile',
  ];

  // ==================== ثوابت الخلفية ====================
// 1. الخلفية الأساسية للـ Scaffold
  Color scaffoldBackgroundColor = Colors.purple;

// 2. تدرج خلفية الـ Body (الجزء الداخلي)
  LinearGradient bodyBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.deepPurple.withOpacity(0.5),  // تأثير بنفسجي خفيف
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI Tools'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==================== الصفحة الرئيسية (Home Page) ====================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ✅ المتغيرات والدوال هنا فقط
  List<SessionModel> learningTracks = [];

  @override
  void initState() {
    super.initState();
    _loadSavedCourses();
  }

  // ✅ دالة لحفظ الكورسات
  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = learningTracks.map((session) => {
      'id': session.id,
      'title': session.title,
      'description': session.description,
      'icon': session.icon,
      'color': session.color.value,
      'courses': session.courses.map((course) => {
        'id': course.id,
        'name': course.name,
        'trainer': course.trainer,
        'progress': course.progress,
        'hours': course.hours,
        'curriculum': course.curriculum.map((lesson) => {
          'title': lesson.title,
          'duration': lesson.duration,
          'type': lesson.type,
          'isCompleted': lesson.isCompleted,
        }).toList(),
      }).toList(),
    }).toList();

    await prefs.setString('saved_courses', json.encode(coursesJson));
  }

  // ✅ دالة لتحميل الكورسات المحفوظة
  Future<void> _loadSavedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('saved_courses');

    if (savedData != null && savedData.isNotEmpty) {
      try {
        final List<dynamic> coursesJson = json.decode(savedData);
        setState(() {
          learningTracks = coursesJson.map((json) => SessionModel(
            id: json['id'],
            title: json['title'],
            description: json['description'],
            icon: json['icon'],
            color: Color(json['color']),
            courses: (json['courses'] as List).map((c) => CourseModel(
              id: c['id'],
              name: c['name'],
              trainer: c['trainer'],
              progress: c['progress'],
              hours: c['hours'],
              curriculum: (c['curriculum'] as List).map((l) => LessonModel(
                title: l['title'],
                duration: l['duration'],
                type: l['type'],
                isCompleted: l['isCompleted'],
              )).toList(),
            )).toList(),
          )).toList();
        });
      } catch (e) {
        print('Error loading saved courses: $e');
      }
    }
  }

  // ✅ دالة لإضافة كورس مسجل
  void _addRegisteredCourse(CourseItem course) {
    setState(() {
      final newTrack = SessionModel(
        id: course.id,
        title: course.title,
        description: course.description,
        icon: '👗',
        color: Colors.deepPurple,
        courses: course.sessions.map((session) => CourseModel(
          id: session.id,
          name: session.title,
          trainer: course.trainerName,
          progress: 0,
          hours: course.totalHours,
          curriculum: session.curriculum.map((lesson) => LessonModel(
            title: lesson.title,
            duration: lesson.duration,
            isCompleted: false,
            videoUrl: lesson.url,
            type: lesson.type,
          )).toList(),
        )).toList(),
      );
      learningTracks.add(newTrack);
      _saveCourses();
    });
  }

  // ✅ دالة للتحقق إذا كان الكورس مسجلاً
  bool isCourseRegistered(String courseId) {
    return learningTracks.any((track) => track.id == courseId);
  }

  // ✅ دالة لحذف كورس من القائمة
  void _unregisterCourse(String courseId) {
    setState(() {
      learningTracks.removeWhere((track) => track.id == courseId);
      _saveCourses();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course removed from your learning tracks'), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة الترحيب
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome 👋', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Marwa Zenalabdin', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Level 3', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.school, color: Colors.white, size: 50),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4 مربعات الخدمات
          Row(
            children: [
              Expanded(child: _buildSquareCard(context, title: 'Job\nOpportunities', icon: Icons.work, color: Colors.orange, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const JobOpportunitiesPage()));
              })),
              const SizedBox(width: 12),
              Expanded(child: _buildSquareCard(context, title: 'Students\nProject', icon: Icons.folder, color: Colors.blue, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentsProjectsPage()));
              })),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSquareCard(context, title: 'Uploaded\nProjects', icon: Icons.folder_open, color: Colors.teal, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadedProjectsPage()));
              })),
              const SizedBox(width: 12),
              Expanded(child: _buildSquareCard(context, title: 'Register\nCourse', icon: Icons.add_circle, color: Colors.deepPurple, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterCoursesPage(
                      onRegister: (courses) {
                        for (var course in courses) {
                          _addRegisteredCourse(course);
                        }
                      },
                      onUnregister: _unregisterCourse,  // ✅ لحذف الكورس
                      registeredCourseIds: learningTracks.map((t) => t.id).toList(),
                    ),
                  ),
                );
              })),
            ],
          ),
          const SizedBox(height: 24),

          // عنوان Learning Tracks مع زر See All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Learning Tracks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (learningTracks.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyCoursesPage(
                          registeredSessions: learningTracks,
                        ),
                      ),
                    );
                  },
                  child: const Text('See All', style: TextStyle(color: Colors.deepPurple, fontSize: 14, fontWeight: FontWeight.w500)),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // قائمة Learning Tracks
          if (learningTracks.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.school_outlined, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No learning tracks yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Tap "Register Course" to start learning', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: learningTracks.length,
              itemBuilder: (context, index) {
                final track = learningTracks[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyCoursesPage(
                          selectedSessionId: track.id,
                          registeredSessions: learningTracks,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, spreadRadius: 2)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: track.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(track.icon, style: const TextStyle(fontSize: 28))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(track.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(track.description, style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 1),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: track.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: Text('${track.courses.length} courses', style: TextStyle(fontSize: 11, color: track.color, fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSquareCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 6),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}