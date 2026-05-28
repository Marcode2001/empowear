// 📄 lib/models/course_models.dart
// ============================================================
// 📦 نماذج بيانات الكورسات - الإصدار النهائي
// ============================================================

import 'package:flutter/material.dart';

// ============================================================
// 📚 نموذج محتوى الكورس (CourseContent)
// ============================================================

class CourseContent {
  final int id;
  final int course;
  final int courseSession;
  final int sessionOrder;
  final String title;
  final String contentType;
  final int contentOrder;
  final String? fileUrl;

  CourseContent({
    required this.id,
    required this.course,
    required this.courseSession,
    required this.sessionOrder,
    required this.title,
    required this.contentType,
    required this.contentOrder,
    this.fileUrl,
  });

  factory CourseContent.fromJson(Map<String, dynamic> json) {
    String? fileUrlValue;

    if (json['file'] != null && json['file'].toString().isNotEmpty) {
      fileUrlValue = json['file'].toString();
    } else if (json['file_url'] != null &&
        json['file_url'].toString().isNotEmpty) {
      fileUrlValue = json['file_url'].toString();
    }

    return CourseContent(
      id: json['id'] ?? 0,
      course: json['course'] ?? 0,
      courseSession: json['course_session'] ?? 0,
      sessionOrder: json['session_order'] ?? 0,
      title: json['title'] ?? 'بدون عنوان',
      contentType: json['content_type'] ?? 'FILE',
      contentOrder: json['content_order'] ?? 0,
      fileUrl: fileUrlValue,
    );
  }

  String get type => contentType.toLowerCase();
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  String get duration => '${(contentOrder * 5).clamp(5, 60)} min';

  IconData get icon {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.video_library;
      case 'image':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color get color {
    switch (type) {
      case 'pdf':
        return Colors.red;
      case 'video':
        return Colors.blue;
      case 'image':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get fullUrl {
    if (!hasFile) return '';

    if (fileUrl!.startsWith('http')) {
      return fileUrl!;
    }

    const baseUrl = 'http://192.168.1.22:8000';

    String relativePath = fileUrl!;
    if (!relativePath.startsWith('/')) {
      relativePath = '/$relativePath';
    }

    if (relativePath.startsWith('/media/')) {
      return '$baseUrl$relativePath';
    }

    return '$baseUrl/media$relativePath';
  }
}

// ============================================================
// 📋 نموذج الدرس
// ============================================================

class Lesson {
  final String id;
  final String title;
  final String duration;
  final String type;
  final String url;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.type,
    required this.url,
    this.isCompleted = false,
  });

  factory Lesson.fromCourseContent(CourseContent content) {
    return Lesson(
      id: content.id.toString(),
      title: content.title,
      duration: content.duration,
      type: content.type,
      url: content.fullUrl,
      isCompleted: false,
    );
  }
}

// ============================================================
// 📋 نموذج الجلسة
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

  factory Session.fromJson(Map<String, dynamic> json) {
    final List<dynamic> contentsData =
        json['contents'] ?? json['course_content'] ?? [];

    return Session(
      id: json['id'] ?? 0,
      course: json['course'] ?? 0,
      courseTitle: json['course_title'] ?? 'كورس غير معروف',
      title: json['session_title'] ?? 'جلسة بدون عنوان',
      description: json['description'] ?? '',
      sessionOrder: json['session_order'],
      contents:
      contentsData.map((c) => CourseContent.fromJson(c)).toList(),
    );
  }

  int get lessonsCount => contents.length;

  List<Lesson> get curriculum =>
      contents.map((c) => Lesson.fromCourseContent(c)).toList();
}

// ============================================================
// 🎓 نموذج الكورس
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

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> sessionsData = json['sessions'] ?? [];

    final priceValue = json['price'];
    final priceString = priceValue is num
        ? priceValue.toStringAsFixed(2)
        : (priceValue?.toString() ?? '0');

    String trainerName = '';

    if (json['trainer_full_name'] != null) {
      trainerName = json['trainer_full_name'];
    } else {
      trainerName = 'مدرب غير معروف';
    }

    return CourseItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'كورس بدون عنوان',
      description: json['description'] ?? '',
      levelNumber: json['level_number'] ?? 1,
      courseType: json['course_type'] ?? 'عام',
      price: priceString,
      toolsRequired: json['tools_required'] ?? '',
      trainerProfile: json['trainer_profile'] ?? 0,
      trainerName: trainerName,

      // 🔥 FIX الأساسي
      studentsCount:
      json['current_enrolled_students_count'] ?? 0,

      totalHours: json['totalHours'] ?? '0h',
      sessions: sessionsData.map((s) => Session.fromJson(s)).toList(),
      isRegistered: json['is_registered'] ?? false,
      progress: json['progress'] ?? 0,
    );
  }

  int get sessionsCount => sessions.length;

  int get totalLessons =>
      sessions.fold(0, (sum, s) => sum + s.lessonsCount);

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