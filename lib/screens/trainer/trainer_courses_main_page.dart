// 📄 lib/screens/trainer/trainer_courses_main_page.dart
// ============================================================
// 🏫 صفحة كورسات المدرب الرئيسية - متوافقة مع تصميم الطالب
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/course/course_bloc.dart';
import '../../bloc/course/course_event.dart';
import '../../bloc/course/course_state.dart';
import '../../models/course_models.dart';
import 'trainer_curriculum_page.dart';

class TrainerCoursesMainPage extends StatefulWidget {
  final String? selectedCourseId;

  const TrainerCoursesMainPage({
    super.key,
    this.selectedCourseId,
  });

  @override
  State<TrainerCoursesMainPage> createState() => _TrainerCoursesMainPageState();
}

class _TrainerCoursesMainPageState extends State<TrainerCoursesMainPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<CourseItem> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CourseBloc>().add(
        LoadTrainerCoursesEvent(
          trainerId: authState.user.id,
        ),
      );
    }
  }

  List<CourseItem> get _filteredCourses {
    if (_searchQuery.isEmpty) return _courses;
    return _courses.where((course) {
      return course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.trainerName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  int get _totalResultsCount => _filteredCourses.length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('My Courses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
          ),
        ),
      ),
      body: BlocListener<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is AvailableCoursesLoaded) {
            setState(() {
              _courses = state.availableCourses;
              _isLoading = false;
            });
          } else if (state is CourseError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
            : _courses.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No courses yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first course to get started',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        )
            : Column(
          children: [
            // حقل البحث
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by course name or trainer...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      }),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$_totalResultsCount results found', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredCourses.isEmpty
                  ? Center(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No courses found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredCourses.length,
                itemBuilder: (context, index) {
                  if (index == _filteredCourses.length - 1) {
                    return Column(
                      children: [
                        _buildCourseCard(_filteredCourses[index]),
                        const SizedBox(height: 80),
                      ],
                    );
                  }
                  return _buildCourseCard(_filteredCourses[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🃏 بناء بطاقة الكورس (مثل تصميم الطالب)
  // ============================================================
  Widget _buildCourseCard(CourseItem course) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrainerCurriculumPage(course: course),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, spreadRadius: 2)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان والمدرب
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(course.trainerName, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // المعلومات الإضافية
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _infoChip("Level ${course.levelNumber}", Icons.bar_chart),
                _infoChip(course.courseType, Icons.category),
                _infoChip("${course.price} \$", Icons.attach_money),
                _infoChip("${course.studentsCount} ${course.studentsCount == 1 ? 'student' : 'students'}", Icons.people),
              ],
            ),

            const SizedBox(height: 8),

            // الأدوات المطلوبة
            if (course.toolsRequired.isNotEmpty)
              Text(
                "Tools: ${course.toolsRequired}",
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ✅ دالة مساعدة لعرض المعلومات بشكل منسدل (Chip)
  Widget _infoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.deepPurple),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}