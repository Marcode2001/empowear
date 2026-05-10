// 📄 lib/models/course_models.dart
// ============================================================
// 📦 نماذج بيانات الكورسات - الإصدار النهائي مع كلاس Lesson
// ============================================================

import 'package:flutter/material.dart';

// ============================================================
// 📚 نموذج محتوى الكورس (CourseContent)
// ============================================================

class CourseContent {
  final int id;
  final int course;
  final int courseSession;
  final String title;
  final String contentType;
  final int contentOrder;
  final String? fileUrl;

  CourseContent({
    required this.id,
    required this.course,
    required this.courseSession,
    required this.title,
    required this.contentType,
    required this.contentOrder,
    this.fileUrl,
  });

  // ✅ تحويل JSON إلى كائن CourseContent
  factory CourseContent.fromJson(Map<String, dynamic> json) {
    return CourseContent(
      id: json['id'] ?? 0,
      course: json['course'] ?? 0,
      courseSession: json['course_session'] ?? 0,
      title: json['title'] ?? 'بدون عنوان',
      contentType: json['content_type'] ?? 'FILE',
      contentOrder: json['content_order'] ?? 0,
      fileUrl: json['file'] ?? json['file_url'],
    );
  }

  // ✅ دوال مساعدة للواجهة
  String get type => contentType.toLowerCase();
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  String get duration => '${(contentOrder * 5).clamp(5, 60)} min';

  IconData get icon {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'video': return Icons.video_library;
      case 'image': return Icons.image;
      default: return Icons.insert_drive_file;
    }
  }

  Color get color {
    switch (type) {
      case 'pdf': return Colors.red;
      case 'video': return Colors.blue;
      case 'image': return Colors.green;
      default: return Colors.grey;
    }
  }
}

// ============================================================
// 📋 نموذج الدرس (Lesson) - جديد للواجهة
// ============================================================
// هذا النموذج يبسط عرض المحتوى في الواجهة

class Lesson {
  final String id;           // معرف الدرس (نص)
  final String title;        // عنوان الدرس
  final String duration;     // المدة (مثل "10 min")
  final String type;         // النوع: 'video', 'pdf', 'image'
  final String url;          // رابط الملف
  final bool isCompleted;    // هل تم إكمال الدرس؟

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.type,
    required this.url,
    this.isCompleted = false,
  });

  // ✅ تحويل من CourseContent إلى Lesson
  factory Lesson.fromCourseContent(CourseContent content) {
    return Lesson(
      id: content.id.toString(),
      title: content.title,
      duration: content.duration,
      type: content.type,
      url: content.fileUrl ?? '',
      isCompleted: false,
    );
  }
}

// ============================================================
// 📋 نموذج الجلسة (Session)
// ============================================================

class Session {
  final int id;
  final int course;
  final String courseTitle;
  final String title;
  final String description;
  final int? sessionOrder;
  final List<CourseContent> contents;

  Session({
    required this.id,
    required this.course,
    required this.courseTitle,
    required this.title,
    required this.description,
    this.sessionOrder,
    this.contents = const [],
  });

  // ✅ تحويل JSON إلى كائن Session
  factory Session.fromJson(Map<String, dynamic> json) {
    final List<dynamic> contentsData = json['contents'] ?? json['course_content'] ?? [];

    return Session(
      id: json['id'] ?? 0,
      course: json['course'] ?? 0,
      courseTitle: json['course_title'] ?? 'كورس غير معروف',
      title: json['session_title'] ?? json['title'] ?? 'جلسة بدون عنوان',
      description: json['description'] ?? '',
      sessionOrder: json['session_order'],
      contents: contentsData.map((c) => CourseContent.fromJson(c)).toList(),
    );
  }

  // ✅ عدد المحتويات في الجلسة
  int get lessonsCount => contents.length;

  // ✅ ✅ ✅ هذه هي الدالة المفقودة (curriculum)
  // تحول قائمة CourseContent إلى قائمة Lesson للواجهة
  List<Lesson> get curriculum {
    return contents.map((content) => Lesson.fromCourseContent(content)).toList();
  }
}

// ============================================================
// 🎓 نموذج الكورس (CourseItem)
// ============================================================

class CourseItem {
  final String id;
  final String title;
  final String description;
  final int levelNumber;
  final String courseType;
  final String price;
  final String toolsRequired;
  final int trainerProfile;
  final String trainerName;
  final int studentsCount;
  final String totalHours;
  final List<Session> sessions;
  final bool isRegistered;
  final int progress;

  CourseItem({
    required this.id,
    required this.title,
    required this.description,
    required this.levelNumber,
    required this.courseType,
    required this.price,
    required this.toolsRequired,
    required this.trainerProfile,
    required this.trainerName,
    this.studentsCount = 0,
    this.totalHours = '0h',
    this.sessions = const [],
    this.isRegistered = false,
    this.progress = 0,
  });

  // ✅ تحويل JSON إلى كائن CourseItem
  factory CourseItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> sessionsData = json['sessions'] ?? [];

    final priceValue = json['price'];
    final priceString = priceValue is num
        ? priceValue.toStringAsFixed(2)
        : (priceValue?.toString() ?? '0');

    String trainerName = '';
    if (json['trainer_full_name'] != null) {
      trainerName = json['trainer_full_name'];
    } else if (json['trainerName'] != null) {
      trainerName = json['trainerName'];
    } else if (json['trainer_profile'] is Map) {
      trainerName = json['trainer_profile']['full_name'] ?? 'مدرب غير معروف';
    } else if (json['trainer_profile'] is int) {
      trainerName = 'مدرب رقم ${json['trainer_profile']}';
    } else {
      trainerName = 'مدرب غير معروف';
    }

    return CourseItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'كورس بدون عنوان',
      description: json['description'] ?? '',
      levelNumber: json['level_number'] ?? json['levelNumber'] ?? 1,
      courseType: json['course_type'] ?? json['courseType'] ?? 'عام',
      price: priceString,
      toolsRequired: json['tools_required'] ?? json['toolsRequired'] ?? '',
      trainerProfile: json['trainer_profile'] is Map
          ? (json['trainer_profile']['id'] ?? 0)
          : (json['trainer_profile'] ?? 0),
      trainerName: trainerName,
      studentsCount: json['studentsCount'] ?? json['students_count'] ?? 0,
      totalHours: json['totalHours'] ?? json['total_hours'] ?? '0h',
      sessions: sessionsData.map((s) => Session.fromJson(s)).toList(),
      isRegistered: json['is_registered'] ?? false,
      progress: json['progress'] ?? 0,
    );
  }

  int get sessionsCount => sessions.length;
  int get totalLessons => sessions.fold(0, (sum, s) => sum + s.lessonsCount);

  CourseItem copyWith({
    String? id,
    String? title,
    String? description,
    int? levelNumber,
    String? courseType,
    String? price,
    String? toolsRequired,
    int? trainerProfile,
    String? trainerName,
    int? studentsCount,
    String? totalHours,
    List<Session>? sessions,
    bool? isRegistered,
    int? progress,
  }) {
    return CourseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      levelNumber: levelNumber ?? this.levelNumber,
      courseType: courseType ?? this.courseType,
      price: price ?? this.price,
      toolsRequired: toolsRequired ?? this.toolsRequired,
      trainerProfile: trainerProfile ?? this.trainerProfile,
      trainerName: trainerName ?? this.trainerName,
      studentsCount: studentsCount ?? this.studentsCount,
      totalHours: totalHours ?? this.totalHours,
      sessions: sessions ?? this.sessions,
      isRegistered: isRegistered ?? this.isRegistered,
      progress: progress ?? this.progress,
    );
  }
}

// نموذج مؤقت لتفاصيل الكورس
class CourseDetail {
  final int id;
  final String title;
  final String description;
  final List<Session> sessions;

  const CourseDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.sessions,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    final List<dynamic> sessionsData = json['sessions'] ?? json['course_sessions'] ?? [];
    return CourseDetail(
      id: json['id'] ?? json['course_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      sessions: sessionsData.map((s) => Session.fromJson(s)).toList(),
    );
  }
}