// 📄 lib/bloc/job/job_event.dart
// ============================================================
// 🎯 الأحداث (Events) الخاصة بفرص العمل
// ============================================================

import 'package:equatable/equatable.dart';
import '../../models/job_models.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();
  @override
  List<Object?> get props => [];
}

// 📍 1. حدث تحميل جميع الوظائف
class LoadJobsEvent extends JobEvent {
  final String? category;
  final String userId;

  const LoadJobsEvent({
    this.category,
    required this.userId,
  });

  @override
  List<Object?> get props => [
    category,
    userId,
  ];
}

// 📍 2. حدث تحميل تفاصيل وظيفة
class LoadJobDetailEvent extends JobEvent {
  final String jobId;
  const LoadJobDetailEvent({required this.jobId});
  @override
  List<Object?> get props => [jobId];
}

// 📍 3. حدث التقديم على وظيفة
class ApplyForJobEvent extends JobEvent {
  final String jobId;
  final String userId;
  final String userName;
  final String userEmail;
  final String? coverLetter;
  final String? resumeUrl;

  const ApplyForJobEvent({
    required this.jobId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.coverLetter,
    this.resumeUrl,
  });

  @override
  List<Object?> get props => [jobId, userId, userName, userEmail];
}



// 📍 5. حدث البحث عن وظائف
class SearchJobsEvent extends JobEvent {
  final String query;
  final String? category;
  const SearchJobsEvent({required this.query, this.category});
  @override
  List<Object?> get props => [query, category];
}

// 📍 6. حدث تحميل طلبات التقديم للمستخدم
class LoadUserApplicationsEvent extends JobEvent {
  final String userId;
  const LoadUserApplicationsEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}

// 📍 7. حدث تحديث حالة التقديم (للمدرب/الأدمن)
class UpdateApplicationStatusEvent extends JobEvent {
  final String applicationId;
  final String newStatus;  // 'approved' أو 'rejected'
  final String userId;

  const UpdateApplicationStatusEvent({
    required this.applicationId,
    required this.newStatus,
    required this.userId,
  });

  @override
  List<Object?> get props => [applicationId, newStatus, userId];
}

// 📍 8. حدث تحديث قائمة طلبات التقديم
class RefreshUserApplicationsEvent extends JobEvent {
  final String userId;

  const RefreshUserApplicationsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}