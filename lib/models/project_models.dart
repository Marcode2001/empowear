// 📄 lib/models/project_models.dart
// ============================================================
// 📁 نماذج البيانات الخاصة بالمشاريع (Project Models)
// ============================================================

import 'package:flutter/material.dart';

// ============================================================
// نموذج المشاريع المميزة (Featured Project)
// ============================================================
class FeaturedProject {
  final String id;
  final String title;
  final String studentId;
  final String studentName;
  final String description;
  final String? imageUrl;
  final String? projectUrl;
  final DateTime? featuredDate;
  final int likesCount;
  final int viewsCount;

  FeaturedProject({
    required this.id,
    required this.title,
    required this.studentId,
    required this.studentName,
    required this.description,
    this.imageUrl,
    this.projectUrl,
    this.featuredDate,
    this.likesCount = 0,
    this.viewsCount = 0,
  });

  // ✅ تحويل JSON إلى FeaturedProject
  factory FeaturedProject.fromJson(Map<String, dynamic> json) {
    return FeaturedProject(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      studentId: json['studentId']?.toString() ?? '',
      studentName: json['studentName'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      projectUrl: json['projectUrl'],
      featuredDate: json['featuredDate'] != null
          ? DateTime.parse(json['featuredDate'])
          : null,
      likesCount: json['likesCount'] ?? 0,
      viewsCount: json['viewsCount'] ?? 0,
    );
  }

  // ✅ تحويل FeaturedProject إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'studentId': studentId,
      'studentName': studentName,
      'description': description,
      'imageUrl': imageUrl,
      'projectUrl': projectUrl,
      'featuredDate': featuredDate?.toIso8601String(),
      'likesCount': likesCount,
      'viewsCount': viewsCount,
    };
  }
}

// ============================================================
// نموذج المشروع المطلوب (Required Project)
// ============================================================
class RequiredProject {
  final String id;
  final String title;
  final String description;
  final int points;
  final DateTime submissionDate;
  final String courseId;
  final String courseName;
  final List<String> attachments;

  RequiredProject({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.submissionDate,
    required this.courseId,
    required this.courseName,
    this.attachments = const [],
  });

  // ✅ تحويل JSON إلى RequiredProject
  factory RequiredProject.fromJson(Map<String, dynamic> json) {
    return RequiredProject(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      points: json['points'] ?? 0,
      // ✅ API Django يرجع submitted_at
      submissionDate: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : DateTime.now(),
      courseId: json['courseId']?.toString() ?? '',
      courseName: json['courseName'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  // ✅ تحويل RequiredProject إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'submissionDate': submissionDate.toIso8601String(),
      'courseId': courseId,
      'courseName': courseName,
      'attachments': attachments,
    };
  }
}

// ============================================================
// نموذج مشروع الطالب (Student Project)
// ============================================================
// ============================================================
// نموذج مشروع الطالب (Student Project)
// ============================================================
class StudentProject {
  final String id;
  final String title;
  final String studentId;
  final String studentName;
  final String description;
  final String? imageUrl;
  final String? projectUrl;
  final DateTime? submissionDate;
  final double? grade;

  // ✅ تقييم API
  final String? gradeLetter;
  final bool? isPassed;

  final String? feedback;
  final String status;

  StudentProject({
    required this.id,
    required this.title,
    required this.studentId,
    required this.studentName,
    required this.description,
    this.imageUrl,
    this.projectUrl,
    this.submissionDate,
    this.gradeLetter,
    this.isPassed,
    this.feedback,
    this.status = 'pending',
    this.grade,
  });

  factory StudentProject.fromJson(Map<String, dynamic> json) {
    return StudentProject(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      studentId: json['trainee_profile']?.toString() ?? '',
      studentName: json['trainee_full_name'] ?? '',
      description: json['session_title'] ?? '',
      imageUrl: json['image'],
      projectUrl: null,
      submissionDate: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : null,

      grade: json['evaluation'] != null
          ? (json['evaluation']['grade'] ?? json['evaluation']['score'])?.toDouble()
          : null,

      gradeLetter: json['evaluation'] != null
          ? json['evaluation']['grade_letter']
          : null,

      isPassed: json['evaluation'] != null
          ? json['evaluation']['is_passed']
          : null,

      feedback: json['feedback'],
      status: json['submission_status'] == 'Evaluated'
          ? 'graded'
          : 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'studentId': studentId,
      'studentName': studentName,
      'description': description,
      'imageUrl': imageUrl,
      'projectUrl': projectUrl,
      'submissionDate': submissionDate?.toIso8601String(),
      'grade': grade,
      'grade_letter': gradeLetter,
      'is_passed': isPassed,
      'feedback': feedback,
      'status': status,
    };
  }
}

// ============================================================
// نموذج تسليم المشروع (Project Submission)
// ============================================================
class ProjectSubmission {
  final String id;
  final String projectId;
  final String studentId;
  final String studentName;
  final String projectUrl;
  final String? description;
  final DateTime submittedAt;
  final double? grade;
  final String? feedback;
  final String status;

  ProjectSubmission({
    required this.id,
    required this.projectId,
    required this.studentId,
    required this.studentName,
    required this.projectUrl,
    this.description,
    required this.submittedAt,
    this.grade,
    this.feedback,
    this.status = 'pending',
  });

  // ✅ تحويل JSON إلى ProjectSubmission
  factory ProjectSubmission.fromJson(Map<String, dynamic> json) {
    return ProjectSubmission(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      studentName: json['studentName'] ?? '',
      projectUrl: json['projectUrl'] ?? '',
      description: json['description'],
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : DateTime.now(),
      grade: json['grade']?.toDouble(),
      feedback: json['feedback'],
      status: json['status'] ?? 'pending',
    );
  }

  // ✅ تحويل ProjectSubmission إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'studentId': studentId,
      'studentName': studentName,
      'projectUrl': projectUrl,
      'description': description,
      'submittedAt': submittedAt.toIso8601String(),
      'grade': grade,
      'feedback': feedback,
      'status': status,
    };
  }
}