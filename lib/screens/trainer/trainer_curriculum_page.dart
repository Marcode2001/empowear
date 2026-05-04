import 'package:flutter/material.dart';
import '../../models/course_models.dart';

class TrainerCurriculumPage extends StatelessWidget {
  final CourseItem course;
  final Session session;
  const TrainerCurriculumPage({super.key, required this.course, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(session.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]))),
      ),
      body: Column(children: [
        // ✅ رأس الجلسة
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Course: ${course.title}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(session.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${session.curriculum.length} Lessons', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ]),
        ),
        const SizedBox(height: 16),
        // ✅ قائمة الدروس (المنهاج) - قراءة فقط
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: session.curriculum.length, itemBuilder: (_, i) {
          final lesson = session.curriculum[i];
          final isVideo = lesson.type == 'video';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: isVideo ? Colors.deepPurple.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Icon(isVideo ? Icons.play_arrow : Icons.picture_as_pdf, color: isVideo ? Colors.deepPurple : Colors.orange, size: 24)),
              ),
              title: Text(lesson.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              subtitle: Row(children: [
                const Icon(Icons.access_time, size: 12, color: Colors.grey), const SizedBox(width: 4),
                Text(lesson.duration, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(width: 12),
                Text(isVideo ? 'Video' : 'PDF', style: TextStyle(fontSize: 10, color: isVideo ? Colors.deepPurple : Colors.orange, fontWeight: FontWeight.w500)),
              ]),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purple]), borderRadius: BorderRadius.circular(20)),
                child: Text(isVideo ? 'Watch' : 'View', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        })),
      ]),
    );
  }
}