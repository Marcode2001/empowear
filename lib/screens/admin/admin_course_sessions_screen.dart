// ============================================================
// 📚 Sessions Page For Admin
// ============================================================

import 'package:flutter/material.dart';
import '../../models/course_models.dart';
import '../../services/api_service.dart';
import 'admin_course_contents_page.dart';

class AdminCourseSessionsPage extends StatefulWidget {

  final CourseItem course;

  const AdminCourseSessionsPage({
    super.key,
    required this.course,
  });

  @override
  State<AdminCourseSessionsPage> createState() =>
      _AdminCourseSessionsPageState();
}

class _AdminCourseSessionsPageState
    extends State<AdminCourseSessionsPage> {

  List<dynamic> sessions = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  // ==========================================================
  // 📥 تحميل الجلسات
  // ==========================================================
  Future<void> loadSessions() async {

    setState(() => isLoading = true);

    try {

      final response = await ApiService.get(
        endpoint:
        'course-session/admin-search-by-course-id/${widget.course.id}/',
        requireAuth: true,
      );

      if (response['success'] == true) {

        setState(() {
          sessions = response['data'];
        });
      }

    } catch (e) {

      debugPrint('ERROR LOAD SESSIONS: $e');

    } finally {

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ==========================================================
  // 🗑️ حذف جلسة
  // ==========================================================
  Future<void> deleteSession(int id) async {

    try {

      final response = await ApiService.delete(
        endpoint: 'course-session/admin-delete/$id/',
        requireAuth: true,
      );

      if (response['success'] == true) {

        loadSessions();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session deleted'),
          ),
        );
      }

    } catch (e) {

      debugPrint(e.toString());

    }
  }

  // ==========================================================
  // ➕ إضافة جلسة
  // ==========================================================
  Future<void> createSession() async {

    final titleController = TextEditingController();
    final orderController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(

          title: const Text('Add Session'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: titleController,
                decoration:
                const InputDecoration(labelText: 'Session Title'),
              ),

              TextField(
                controller: orderController,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: 'Session Order'),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {

                try {

                  final response = await ApiService.post(
                    endpoint: 'course-session/admin-create/',
                    requireAuth: true,
                    data: {

                      // ✅ الكورس الحالي
                      'course': widget.course.id,

                      // ✅ عنوان الجلسة
                      'session_title': titleController.text,

                      // ✅ ترتيب الجلسة
                      'session_order':
                      int.parse(orderController.text),
                    },
                  );

                  if (response['success'] == true) {

                    Navigator.pop(context);

                    loadSessions();
                  }

                } catch (e) {

                  debugPrint(e.toString());

                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.course.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // ✅ تغيير لون سهم الرجوع إلى الأبيض
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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

      // ✅ تغيير لون علامة الزائد إلى الأبيض
      floatingActionButton: FloatingActionButton(
        onPressed: createSession,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (_, index) {
          final session = sessions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              // ✅ اسم الجلسة
              title: Text(
                session['session_title'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // ✅ ترتيب الجلسة
              subtitle: Text(
                'Order: ${session['session_order']}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              // ✅ فتح المحتوى
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminCourseContentsPage(
                      courseId: widget.course.id,
                      session: session,
                    ),
                  ),
                );
              },
              // ✅ حذف الجلسة
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () => deleteSession(session['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}