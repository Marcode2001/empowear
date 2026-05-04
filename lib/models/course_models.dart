import 'package:flutter/material.dart';

// ==================== نموذج الدرس (Lesson) ====================
class Lesson {
  final String id;
  final String title;
  final String duration;
  final String type;  // 'video' or 'pdf'
  final String url;

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.type,
    required this.url,
  });
}

// ==================== نموذج الجلسة (Session) ====================
class Session {
  final String id;
  final String title;
  final String description;
  final List<Lesson> curriculum;  // ✅ المنهاج موجود هنا

  Session({
    required this.id,
    required this.title,
    required this.description,
    required this.curriculum,
  });
}

// ==================== نموذج الكورس (Course) ====================
class CourseItem {
  final String id;
  final String title;
  final String description;
  final int levelNumber;
  final String price;
  final String totalHours;
  final String trainerName;
  final List<Session> sessions;
  bool isRegistered;

  CourseItem({
    required this.id,
    required this.title,
    required this.description,
    required this.levelNumber,
    required this.price,
    required this.totalHours,
    required this.trainerName,
    required this.sessions,
    this.isRegistered = false,
  });
}