// 📄 lib/bloc/job/job_state.dart
// ============================================================
// 🎯 الحالات (States) الخاصة بفرص العمل
// ============================================================

import 'package:equatable/equatable.dart';
import '../../models/job_models.dart';

abstract class JobState extends Equatable {
  const JobState();
  @override
  List<Object?> get props => [];
}

// الحالة الابتدائية
class JobInitial extends JobState {
  const JobInitial();

  @override
  List<Object?> get props => [];
}

// حالة التحميل
class JobLoading extends JobState {
  const JobLoading();

  @override
  List<Object?> get props => [];
}

// تم تحميل الوظائف
class JobsLoaded extends JobState {

  final List<JobModel> jobs;
  final int totalCount;
  final List<JobApplication> applications;

  const JobsLoaded({
    required this.jobs,
    required this.totalCount,
    this.applications = const [],
  });

  @override
  List<Object?> get props => [
    jobs,
    totalCount,
    applications,
  ];
}

// تم تحميل تفاصيل وظيفة
class JobDetailLoaded extends JobState {
  final JobModel job;
  const JobDetailLoaded({required this.job});
  @override
  List<Object?> get props => [job];
}

// تم التقديم على وظيفة
class JobApplied extends JobState {
  final String message;
  final String jobId;
  const JobApplied({required this.message, required this.jobId});
  @override
  List<Object?> get props => [message, jobId];
}



// تم تحميل طلبات التقديم للمستخدم
class UserApplicationsLoaded extends JobState {
  final List<JobApplication> applications;
  const UserApplicationsLoaded({required this.applications});
  @override
  List<Object?> get props => [applications];
}

// حالة الخطأ
class JobError extends JobState {
  final String message;
  const JobError({required this.message});
  @override
  List<Object?> get props => [message];
}

// تم تحديث حالة التقديم
class ApplicationStatusUpdated extends JobState {
  final String message;
  final ApplicationStatus newStatus;
  const ApplicationStatusUpdated({required this.message, required this.newStatus});
  @override
  List<Object?> get props => [message, newStatus];
}