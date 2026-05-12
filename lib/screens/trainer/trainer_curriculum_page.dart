// 📄 lib/screens/trainer/trainer_curriculum_page.dart
// ============================================================
// 📖 صفحة المنهاج للمدرب - تعرض الجلسات والمحتوى
// ============================================================

import 'package:flutter/material.dart';
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
    setState(() => _isLoading = true);
    try {
      final sessions = await CourseRepository().getCourseSessionsWithContent(widget.course.id);
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading sessions: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          // رأس الكورس
          Container(
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
                  '${widget.course.sessionsCount} Sessions',
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sessions.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No sessions available', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                return _buildSessionCard(session);
              },
            ),
          ),
        ],
      ),
    );
  }

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
          child: const Icon(Icons.video_library, color: Colors.white, size: 24),
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
          )
        ]
            : session.contents.map((content) => _buildContentCard(content)).toList(),
      ),
    );
  }

  Widget _buildContentCard(CourseContent content) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isVideo ? Colors.deepPurple.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    content.contentType.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: isVideo ? Colors.deepPurple : Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Container(
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
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}