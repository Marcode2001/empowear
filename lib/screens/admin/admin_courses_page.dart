// 📄 lib/screens/admin/admin_courses_page.dart
// ============================================================
// 📚 صفحة إدارة الكورسات للأدمن
// ============================================================

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/course_models.dart';
import 'admin_course_sessions_screen.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  List<CourseItem> _courses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get(
        endpoint: 'course/admin-all-courses/',
        requireAuth: true,
      );

      if (response['success'] == true && response['data'] is List) {
        setState(() {
          _courses = (response['data'] as List)
              .map((json) => CourseItem.fromJson(json))
              .toList();
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load courses';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createCourse({
    required String title,
    required String description,
    required int levelNumber,
    required String courseType,
    required double price,
    required String toolsRequired,
    required int trainerProfile,
  }) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post(
        endpoint: 'course/admin-create/',
        data: {
          'title': title,
          'description': description,
          'level_number': levelNumber,
          'course_type': courseType,
          'price': price,
          'tools_required': toolsRequired,
          'trainer_profile': trainerProfile,
        },
        requireAuth: true,
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course created successfully'), backgroundColor: Colors.green),
          );
          await _loadCourses();
        }
      } else {
        throw Exception(response['message'] ?? 'Creation failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteCourse(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure? All sessions and content will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.delete(
        endpoint: 'course/admin-delete/$id/',
        requireAuth: true,
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course deleted successfully'), backgroundColor: Colors.green),
          );
          await _loadCourses();
        }
      } else {
        throw Exception(response['message'] ?? 'Deletion failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final levelCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final toolsCtrl = TextEditingController();
    final trainerIdCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Course'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Course Title *'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                TextFormField(
                  controller: levelCtrl,
                  decoration: const InputDecoration(labelText: 'Level Number *'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: typeCtrl,
                  decoration: const InputDecoration(labelText: 'Course Type (Theory/Practical)'),
                ),
                TextFormField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Price *'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: toolsCtrl,
                  decoration: const InputDecoration(labelText: 'Tools Required'),
                ),
                TextFormField(
                  controller: trainerIdCtrl,
                  decoration: const InputDecoration(labelText: 'Trainer Profile ID *'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _createCourse(
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  levelNumber: int.parse(levelCtrl.text),
                  courseType: typeCtrl.text,
                  price: double.parse(priceCtrl.text),
                  toolsRequired: toolsCtrl.text,
                  trainerProfile: int.parse(trainerIdCtrl.text),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Courses',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple,
                Colors.purple,
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCourses,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _courses.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No courses found', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text('Tap + to add a course', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _courses.length,
        itemBuilder: (ctx, index) {
          final course = _courses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(

              // ✅ فتح الجلسات
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminCourseSessionsPage(
                      course: course,
                    ),
                  ),
                );
              },

              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.deepPurple,
                      Colors.purple,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${course.levelNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ✅ عنوان الكورس رجّعناه
              title: Text(
                course.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 4),

                  Text(
                    course.trainerName,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '\$${course.price}',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.deepPurple,
                  ),

                  const SizedBox(width: 8),

                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () =>
                        _deleteCourse(int.parse(course.id)),
                  ),
                ],
              ),
            )
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}