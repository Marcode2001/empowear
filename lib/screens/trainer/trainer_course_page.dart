import 'package:flutter/material.dart';
import '../../models/course_models.dart';
import 'trainer_courses_detail_page.dart';

class TrainerCoursePage extends StatelessWidget {
  final List<CourseItem> courses;
  const TrainerCoursePage({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Courses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purple]))),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrainerCoursesDetailPage(course: course))),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)]),
              child: Row(children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.menu_book, color: Colors.deepPurple, size: 28))),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(course.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Trainer: ${course.trainerName}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text('${course.sessions.length} Sessions • ${course.totalHours} • Level ${course.levelNumber}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ])),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ]),
            ),
          );
        },
      ),
    );
  }
}