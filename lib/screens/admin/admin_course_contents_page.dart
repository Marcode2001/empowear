// ============================================================
// 📄 Course Contents Page
// ============================================================

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminCourseContentsPage extends StatefulWidget {

  final dynamic session;
  final dynamic courseId;

  const AdminCourseContentsPage({
    super.key,
    required this.session,
    required this.courseId,
  });

  @override
  State<AdminCourseContentsPage> createState() =>
      _AdminCourseContentsPageState();
}

class _AdminCourseContentsPageState
    extends State<AdminCourseContentsPage> {

  List<dynamic> contents = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadContents();
  }

  // ==========================================================
  // 📥 تحميل المحتويات
  // ==========================================================
  Future<void> loadContents() async {

    try {

      final response = await ApiService.get(

        endpoint:
        'course-content/admin-search-by-course-id-and-session-order/${widget.courseId}/${widget.session['session_order']}/',

        requireAuth: true,
      );

      if (response['success'] == true) {

        setState(() {
          contents = response['data'];
        });
      }

    } catch (e) {

      debugPrint(e.toString());

    } finally {

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ==========================================================
  // 🗑️ حذف محتوى
  // ==========================================================
  Future<void> deleteContent(int id) async {

    try {

      final response = await ApiService.delete(
        endpoint: 'course-content/admin-delete/$id/',
        requireAuth: true,
      );

      if (response['success'] == true) {

        loadContents();
      }

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          widget.session['session_title'],
          style: const TextStyle(
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {

          // TODO: صفحة رفع المحتوى

        },
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(

        itemCount: contents.length,

        itemBuilder: (_, index) {

          final item = contents[index];

          return Card(

            child: ListTile(

              title: Text(
                item['title'] ?? '',
              ),

              subtitle: Text(
                item['content_type'] ?? '',
              ),

              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () =>
                    deleteContent(item['id']),

              ),
            ),
          );
        },
      ),
    );
  }
}