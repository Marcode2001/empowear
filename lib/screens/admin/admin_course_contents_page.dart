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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Content deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {

      debugPrint(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // ➕ إضافة محتوى (TODO)
  // ==========================================================
  void _showAddContentDialog() {
    // TODO: إضافة صفحة رفع المحتوى
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add content feature coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
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
        backgroundColor: Colors.deepPurple,
        onPressed: _showAddContentDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : contents.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No content available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add content',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contents.length,
        itemBuilder: (_, index) {
          final item = contents[index];

          // ✅ تحديد الأيقونة حسب نوع المحتوى
          IconData iconData;
          Color iconColor;

          switch (item['content_type']?.toString().toLowerCase()) {
            case 'pdf':
              iconData = Icons.picture_as_pdf;
              iconColor = Colors.red;
              break;
            case 'video':
              iconData = Icons.video_library;
              iconColor = Colors.blue;
              break;
            case 'image':
              iconData = Icons.image;
              iconColor = Colors.green;
              break;
            default:
              iconData = Icons.insert_drive_file;
              iconColor = Colors.grey;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 24,
                ),
              ),
              title: Text(
                item['title'] ?? 'Untitled',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Type: ${item['content_type'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (item['content_order'] != null)
                    Text(
                      'Order: ${item['content_order']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () => deleteContent(item['id']),
              ),
              onTap: () {
                // TODO: عرض المحتوى
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Viewing: ${item['title']}'),
                    backgroundColor: Colors.deepPurple,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}