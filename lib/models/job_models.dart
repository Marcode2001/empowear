// 📄 lib/models/job_models.dart
// ============================================================
// نماذج البيانات لفرص العمل والتقديمات
// ✅ مصحح خطأ DateTime? + متوافق مع BLoC Pattern
// ============================================================

import 'package:flutter/material.dart';

// ============================================================
// 📋 نموذج الوظيفة (JobModel)
// ============================================================
class JobModel {
  final String id;
  final String title;
  final String company;
  final String companyLogo;
  final String location;
  final String type;
  final String category;
  final String salary;
  final String description;
  final List<String> requirements;
  final DateTime postedDate;      // ✅ غير قابل للـ null
  final DateTime deadline;        // ✅ غير قابل للـ null
  final bool isRemote;
  final String experience;
  final String? imageUrl;
  final bool isApplied;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.companyLogo,
    required this.location,
    required this.type,
    required this.category,
    required this.salary,
    required this.description,
    required this.requirements,
    required this.postedDate,     // ✅ مطلوب غير قابل للـ null
    required this.deadline,       // ✅ مطلوب غير قابل للـ null
    required this.isRemote,
    required this.experience,
    this.imageUrl,
    this.isApplied = false,
  });

  // ✅ تحويل من JSON إلى JobModel
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      companyLogo: json['companyLogo'] ?? '🏢',
      location: json['location'] ?? '',
      type: json['type'] ?? 'Full-time',
      category: json['category'] ?? 'business',
      salary: json['salary'] ?? '',
      description: json['description'] ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
      // ✅ الحل: إضافة ?? DateTime.now() لتجنب الخطأ
      postedDate: _parseDate(json['postedDate']) ?? DateTime.now(),
      deadline: _parseDate(json['deadline']) ?? DateTime.now().add(const Duration(days: 30)),
      isRemote: json['isRemote'] ?? false,
      experience: json['experience'] ?? 'Entry-Level',
      imageUrl: json['imageUrl'],
      isApplied: json['isApplied'] ?? false,
    );
  }

  // ✅ دالة مساعدة لتحليل التاريخ بأمان (ترجع DateTime?)
  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // ✅ تحويل من JobModel إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'companyLogo': companyLogo,
      'location': location,
      'type': type,
      'category': category,
      'salary': salary,
      'description': description,
      'requirements': requirements,
      'postedDate': postedDate.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'isRemote': isRemote,
      'experience': experience,
      'imageUrl': imageUrl,
      'isApplied': isApplied,
    };
  }

  // ✅ دالة copyWith لتحديث الحقول بشكل آمن
  JobModel copyWith({
    String? id,
    String? title,
    String? company,
    String? companyLogo,
    String? location,
    String? type,
    String? category,
    String? salary,
    String? description,
    List<String>? requirements,
    DateTime? postedDate,
    DateTime? deadline,
    bool? isRemote,
    String? experience,
    String? imageUrl,
    bool? isApplied,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyLogo: companyLogo ?? this.companyLogo,
      location: location ?? this.location,
      type: type ?? this.type,
      category: category ?? this.category,
      salary: salary ?? this.salary,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      postedDate: postedDate ?? this.postedDate,  // ✅ إذا جاء null، استخدم القيمة الحالية
      deadline: deadline ?? this.deadline,        // ✅ إذا جاء null، استخدم القيمة الحالية
      isRemote: isRemote ?? this.isRemote,
      experience: experience ?? this.experience,
      imageUrl: imageUrl ?? this.imageUrl,
      isApplied: isApplied ?? this.isApplied,
    );
  }

  // ✅ مقارنة بين وظيفتين (مفيدة للـ List updates)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================================
// 📊 حالة طلب التقديم على وظيفة (Enum)
// ============================================================
enum ApplicationStatus {
  pending,    // ⏳ قيد المراجعة
  approved,   // ✅ تمت الموافقة
  rejected,   // ❌ مرفوض
}

// ✅ دوال مساعدة للتعامل مع الـ Enum كنص
extension ApplicationStatusExtension on ApplicationStatus {
  String get value {
    switch (this) {
      case ApplicationStatus.pending: return 'pending';
      case ApplicationStatus.approved: return 'approved';
      case ApplicationStatus.rejected: return 'rejected';
    }
  }

  static ApplicationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'approved': return ApplicationStatus.approved;
      case 'rejected': return ApplicationStatus.rejected;
      default: return ApplicationStatus.pending;
    }
  }
}

// ============================================================
// 📝 نموذج طلب التقديم (JobApplication)
// ============================================================
class JobApplication {
  final String id;
  final String jobId;
  final String jobTitle;
  final String company;
  final String companyLogo;
  final String location;
  final String salary;
  final DateTime appliedDate;     // ✅ غير قابل للـ null
  final ApplicationStatus status;
  final String? feedback;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.companyLogo,
    required this.location,
    required this.salary,
    required this.appliedDate,    // ✅ مطلوب غير قابل للـ null
    required this.status,
    this.feedback,
  });

  // ✅ تحويل من JSON إلى JobApplication
  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id']?.toString() ?? '',
      jobId: json['jobId']?.toString() ?? '',
      jobTitle: json['jobTitle'] ?? '',
      company: json['company'] ?? '',
      companyLogo: json['companyLogo'] ?? '🏢',
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      // ✅ الحل: إضافة ?? DateTime.now() لتجنب الخطأ
      appliedDate: JobModel._parseDate(json['appliedDate']) ?? DateTime.now(),
      status: ApplicationStatusExtension.fromString(json['status'] ?? 'pending'),
      feedback: json['feedback'],
    );
  }

  // ✅ تحويل من JobApplication إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'company': company,
      'companyLogo': companyLogo,
      'location': location,
      'salary': salary,
      'appliedDate': appliedDate.toIso8601String(),
      'status': status.value,
      'feedback': feedback,
    };
  }

  // ✅ دالة copyWith للتحديث
  JobApplication copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? company,
    String? companyLogo,
    String? location,
    String? salary,
    DateTime? appliedDate,
    ApplicationStatus? status,
    String? feedback,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      companyLogo: companyLogo ?? this.companyLogo,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      appliedDate: appliedDate ?? this.appliedDate,  // ✅ إذا جاء null، استخدم القيمة الحالية
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
    );
  }

  // ✅ نصوص مساعدة للواجهة
  String get statusLabel {
    switch (status) {
      case ApplicationStatus.approved: return 'Approved';
      case ApplicationStatus.rejected: return 'Rejected';
      default: return 'Pending Review';
    }
  }

  Color get statusColor {
    switch (status) {
      case ApplicationStatus.approved: return Colors.green;
      case ApplicationStatus.rejected: return Colors.red;
      default: return Colors.orange;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case ApplicationStatus.approved: return Icons.check_circle;
      case ApplicationStatus.rejected: return Icons.cancel;
      default: return Icons.hourglass_empty;
    }
  }

  // ✅ مقارنة بين طلبين
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobApplication && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================================
// 🗂️ نموذج فئة الوظائف (للفلترة)
// ============================================================
class JobCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;

  const JobCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<JobCategory> all = [
    JobCategory(id: 'all', name: 'All', icon: '📋', color: Colors.grey),
    JobCategory(id: 'design', name: 'Design', icon: '🎨', color: Colors.pink),
    JobCategory(id: 'sewing', name: 'Sewing', icon: '🧵', color: Colors.orange),
    JobCategory(id: 'pattern', name: 'Pattern Making', icon: '✂️', color: Colors.deepPurple),
    JobCategory(id: 'digital', name: 'Digital', icon: '💻', color: Colors.blue),
    JobCategory(id: 'business', name: 'Business', icon: '💼', color: Colors.teal),
  ];

  static JobCategory fromId(String id) {
    return all.firstWhere((c) => c.id == id, orElse: () => all.first);
  }
}