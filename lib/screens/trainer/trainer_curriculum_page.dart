// 📄 lib/screens/trainer/trainer_curriculum_page.dart
// ============================================================

import 'dart:io';
import '../trainee/content_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../models/course_models.dart';
import '../../repositories/course_repository.dart';

class TrainerCurriculumPage extends StatefulWidget {
  final CourseItem course;

  const TrainerCurriculumPage({super.key, required this.course});

  @override
  State<TrainerCurriculumPage> createState() => _TrainerCurriculumPageState();
}

class _TrainerCurriculumPageState extends State<TrainerCurriculumPage> {
  List<Session> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final sessions = await CourseRepository()
          .getTrainerSessionsWithContent(widget.course.id);

      if (!mounted) return;

      setState(() {
        _sessions = sessions ?? [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading sessions: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _sessions = [];
      });
    }
  }

  // ==========================================================
  // PDF داخل التطبيق
  // ==========================================================
  Future<void> _openPdfInsideApp(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception("Failed to download PDF");
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');

      await file.writeAsBytes(response.bodyBytes);

      final result = await OpenFile.open(file.path);

      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      debugPrint('❌ PDF error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Error: $e')),
        );
      }
    }
  }

  // ==========================================================
  // فتح المحتوى
  // ==========================================================
  Future<void> _openContent(CourseContent content) async {
    try {
      if (!content.hasFile) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file available')),
        );
        return;
      }

      final type = content.contentType.toLowerCase();

      // ✅ الفيديو والصور وPDF كلها داخل نفس الصفحة
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ContentViewerPage(content: content),
        ),
      );

    } catch (e) {
      debugPrint('❌ Error opening content: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ==========================================================
  // UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sessions.isEmpty
                ? const Center(child: Text('No sessions available'))
                : ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                return _buildSessionCard(_sessions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // Session Card
  // ==========================================================
  Widget _buildSessionCard(Session session) {
    return ExpansionTile(
      title: Text(session.title),
      children: session.contents.map(_buildContentCard).toList(),
    );
  }

  // ==========================================================
  // Content Card
  // ==========================================================
  Widget _buildContentCard(CourseContent content) {
    final type = content.contentType.toLowerCase();

    final isVideo = type == 'video';
    final isPdf = type == 'pdf';

    return ListTile(
      leading: Icon(
        isVideo
            ? Icons.play_arrow
            : isPdf
            ? Icons.picture_as_pdf
            : Icons.insert_drive_file,
      ),
      title: Text(content.title),
      subtitle: Text(content.contentType.toUpperCase()),
      trailing: const Icon(Icons.open_in_new),

      onTap: () => _openContent(content),
    );
  }
}