// 📄 lib/screens/trainer/trainer_courses_main_page.dart
// ============================================================
// 🏫 صفحة كورسات المدرب الرئيسية - متوافقة مع API
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
      context.read<CourseBloc>().add(LoadRegisteredCoursesEvent(userId: authState.user.id , userType: authState.user.userType,));
    }
  }

  List<CourseItem> get _filteredCourses {
    if (_searchQuery.isEmpty) return _courses;
    return _courses.where((course) {
      return course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.trainerName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

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
          if (state is RegisteredCoursesLoaded) {
            setState(() {
              _courses = state.registeredCourses;
              _isLoading = false;
            });
          } else if (state is CourseError) {
            setState(() => _isLoading = false);
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
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
                    hintText: 'Search by course name...',
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
                child: Text('${_filteredCourses.length} results found', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredCourses.length,
                itemBuilder: (context, index) => _buildCourseCard(_filteredCourses[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.menu_book, color: Colors.white, size: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${course.studentsCount} students', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text('${course.sessions.length} sessions', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text('Level ${course.levelNumber}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}