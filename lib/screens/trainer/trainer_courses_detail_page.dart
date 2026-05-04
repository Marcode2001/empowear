import 'package:flutter/material.dart';
import '../../models/course_models.dart';
import 'trainer_curriculum_page.dart';

class TrainerCoursesDetailPage extends StatelessWidget {
  final CourseItem course;
  const TrainerCoursesDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]))),
      ),
      body: Column(children: [
        // ✅ رأس الكورس: معلومات عامة
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(course.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(course.description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.person, size: 14, color: Colors.deepPurple), const SizedBox(width: 4), Text(course.trainerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple))])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(course.totalHours, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, size: 14, color: Colors.orange), const SizedBox(width: 4), Text('Level ${course.levelNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange))])),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        // ✅ عنوان الجلسات
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
          const Icon(Icons.folder_open, color: Colors.deepPurple), const SizedBox(width: 8),
          Text('Sessions (${course.sessions.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ])),
        const SizedBox(height: 8),
        // ✅ قائمة الجلسات داخل الكورس
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: course.sessions.length, itemBuilder: (_, i) {
          final session = course.sessions[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrainerCurriculumPage(course: course, session: session))),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)]),
              child: Row(children: [
                Container(width: 45, height: 45, decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.deepPurple, size: 24))),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(session.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(session.description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text('${session.curriculum.length} Lessons', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ])),
                const Icon(Icons.chevron_right, color: Colors.deepPurple, size: 24),
              ]),
            ),
          );
        })),
      ]),
    );
  }
}