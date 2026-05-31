// 📄 lib/screens/trainer/trainer_curriculum_page.dart
// ============================================================
// 📖 صفحة المنهاج للمدرب - متوافقة مع تصميم الطالب
// ============================================================

import 'package:flutter/material.dart';
import '../trainee/content_viewer_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple])),
        ),
      ),
      body: Column(
        children: [
          // رأس الكورس (مثل صفحة الطالب)
          _buildCourseHeader(),
          const SizedBox(height: 16),

          // عنوان المنهاج
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text('Curriculum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // قائمة الجلسات
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                : _sessions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                if (index == _sessions.length - 1) {
                  return Column(
                    children: [
                      _buildSessionCard(_sessions[index]),
                      const SizedBox(height: 60),
                    ],
                  );
                }
                return _buildSessionCard(_sessions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🎨 رأس الكورس (Header)
  // ============================================================
  Widget _buildCourseHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            widget.course.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Trainer: ${widget.course.trainerName}',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(Icons.bar_chart, 'Level ${widget.course.levelNumber}'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.people, '${widget.course.studentsCount} students'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.category, widget.course.courseType),
            ],
          ),
        ],
      ),
    );
  }

  // شريط معلومات صغير
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  // حالة عدم وجود جلسات
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No sessions available for this course yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // 🎴 بطاقة الجلسة (مثل صفحة الطالب)
  // ============================================================
  Widget _buildSessionCard(Session session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.file_copy_rounded, color: Colors.white, size: 24),
        ),
        title: Text(
          session.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              session.description.isNotEmpty ? session.description : 'No description',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '${session.lessonsCount} lessons',
              style: TextStyle(fontSize: 11, color: Colors.deepPurple),
            ),
          ],
        ),
        children: session.contents.isEmpty
            ? [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No content available for this session'),
          ),
          const SizedBox(height: 8),
        ]
            : session.contents.map((content) => _buildLessonCard(content)).toList(),
      ),
    );
  }

  // ============================================================
  // 📄 بطاقة الدرس (مثل صفحة الطالب)
  // ============================================================
  Widget _buildLessonCard(CourseContent content) {
    final isVideo = content.contentType.toLowerCase() == 'video';
    final isPdf = content.contentType.toLowerCase() == 'pdf';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // أيقونة الدرس
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isVideo
                  ? const LinearGradient(colors: [Colors.deepPurple, Colors.purple])
                  : (isPdf
                  ? const LinearGradient(colors: [Colors.red, Colors.deepOrange])
                  : const LinearGradient(colors: [Colors.blue, Colors.lightBlue])),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isVideo ? Icons.play_arrow : (isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // معلومات الدرس
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isVideo ? Colors.deepPurple.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        content.contentType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: isVideo ? Colors.deepPurple : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Part ${content.contentOrder}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // زر فتح الملف
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContentViewerPage(content: content),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isVideo
                    ? const LinearGradient(colors: [Colors.deepPurple, Colors.purple])
                    : (isPdf
                    ? const LinearGradient(colors: [Colors.red, Colors.deepOrange])
                    : const LinearGradient(colors: [Colors.blue, Colors.lightBlue])),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isVideo ? 'Watch' : (isPdf ? 'View PDF' : 'Open'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}