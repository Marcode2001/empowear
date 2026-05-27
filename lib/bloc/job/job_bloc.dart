// 📄 lib/bloc/job/job_bloc.dart
// ============================================================
// 💼 Job Bloc - Complete
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/job_models.dart';
import '../../repositories/job_repository.dart';
import 'job_event.dart';
import 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final JobRepository _jobRepository;

  // 💾 تخزين مؤقت للوظائف وطلبات التقديم
  List<JobModel> _allJobs = [];
  List<JobApplication> _userApplications = [];

  JobBloc({required JobRepository jobRepository})
      : _jobRepository = jobRepository,
        super(const JobInitial()) {
    // 🎯 ربط الأحداث مع دوال المعالجة
    on<LoadJobsEvent>(_onLoadJobs);
    on<LoadJobDetailEvent>(_onLoadJobDetail);
    on<ApplyForJobEvent>(_onApplyForJobEvent);

    on<SearchJobsEvent>(_onSearchJobsEvent);
    on<LoadUserApplicationsEvent>(_onLoadUserApplications);
    on<UpdateApplicationStatusEvent>(_onUpdateApplicationStatus);
    on<RefreshUserApplicationsEvent>(_onRefreshUserApplications);
  }

  // ============================================================
  // 📍 1. تحميل جميع الوظائف
  // ============================================================
  // ============================================================
// 📍 1. تحميل جميع الوظائف
// ============================================================
  // ============================================================
// 📍 1. تحميل جميع الوظائف
// ============================================================

  Future<void> _onLoadJobs(
      LoadJobsEvent event,
      Emitter<JobState> emit,
      ) async {

    try {

      // ✅ جلب الوظائف
      final jobs = await _jobRepository.fetchJobs(
        category: event.category,
      );

      // ✅ جلب التقديمات الحالية للمستخدم
      final applications =
      await _jobRepository.fetchUserApplications(
        'current_user',
      );

      // ✅ تخزينهم محلياً
      _userApplications = applications;

      // ✅ استخراج IDs الوظائف المقدم عليها
      final appliedJobIds = applications
          .map((e) => e.jobId.toString())
          .toSet();

      print('📌 Applied IDs: $appliedJobIds');

      // ✅ تحديث حالة الوظائف
      _allJobs = jobs.map((job) {

        final isApplied =
        appliedJobIds.contains(
          job.id.toString(),
        );

        print(
          '🧪 JOB ${job.id} => isApplied = $isApplied',
        );

        return job.copyWith(
          isApplied: isApplied,
        );

      }).toList();

      // ✅ إرسال البيانات كاملة
      emit(
        JobsLoaded(
          jobs: _allJobs,
          totalCount: _allJobs.length,
          applications: _userApplications,
        ),
      );

    } catch (e) {

      emit(
        JobError(
          message:
          'Failed to load jobs: ${e.toString()}',
        ),
      );
    }
  }

  // ============================================================
  // 📍 2. تحميل تفاصيل وظيفة
  // ============================================================
  Future<void> _onLoadJobDetail(
      LoadJobDetailEvent event,
      Emitter<JobState> emit,
      ) async {
    emit(const JobLoading());
    try {
      final job = await _jobRepository.fetchJobDetail(event.jobId);
      emit(JobDetailLoaded(job: job));
    } catch (e) {
      emit(JobError(message: 'Failed to load job details: ${e.toString()}'));
    }
  }

  // ============================================================
  // 📍 3. التقديم على وظيفة
  // ============================================================
  Future<void> _onApplyForJobEvent(
      ApplyForJobEvent event,
      Emitter<JobState> emit,
      ) async {
    try {
      final success = await _jobRepository.applyForJob(
        jobId: event.jobId,
        userId: event.userId,
        userName: event.userName,
        userEmail: event.userEmail,
        coverLetter: event.coverLetter,
        resumeUrl: event.resumeUrl,
      );

      if (success) {
        // ✅ تحديث حالة الوظيفة في القائمة المحلية
        _allJobs = _allJobs.map((job) {
          if (job.id == event.jobId) {
            return job.copyWith(isApplied: true);
          }
          return job;
        }).toList();

        // ✅ إضافة طلب تقديم جديد إلى القائمة المحلية
        final jobData = _allJobs.firstWhere(
              (j) => j.id == event.jobId,
          orElse: () => _getMockJob(event.jobId),
        );

        final newApplication = JobApplication(
          id: '${event.jobId}_${event.userId}',
          jobId: event.jobId,
          jobTitle: jobData.title,
          company: jobData.company,
          companyLogo: jobData.companyLogo,
          location: jobData.location,
          salary: jobData.salary,
          appliedDate: DateTime.now(),
          status: ApplicationStatus.pending,
        );

        _userApplications = [newApplication, ..._userApplications];
        // ✅ تحديث الوظائف مباشرة
        _allJobs = _allJobs.map((job) {

          if (job.id == event.jobId) {

            return job.copyWith(
              isApplied: true,
            );
          }

          return job;

        }).toList();

        emit(
          JobsLoaded(
            jobs: _allJobs,
            totalCount: _allJobs.length,
            applications: _userApplications,
          ),
        );
        emit(UserApplicationsLoaded(applications: _userApplications));
        emit(JobApplied(message: 'Application submitted!', jobId: event.jobId));
      } else {
        emit(JobError(message: 'Failed to submit application'));
      }
    } catch (e) {
      emit(JobError(message: 'Error applying for job: ${e.toString()}'));
    }
  }

  // ============================================================
  // 📍 4. سحب التقديم على وظيفة
  // ============================================================


  // ============================================================
  // 📍 5. البحث عن وظائف
  // ============================================================
  Future<void> _onSearchJobsEvent(
      SearchJobsEvent event,
      Emitter<JobState> emit,
      ) async {
    var filteredJobs = List<JobModel>.from(_allJobs);

    if (event.category != null && event.category != 'all') {
      filteredJobs = filteredJobs
          .where((job) => job.category == event.category)
          .toList();
    }

    if (event.query.isNotEmpty) {
      final query = event.query.toLowerCase();
      filteredJobs = filteredJobs.where((job) =>
      job.title.toLowerCase().contains(query) ||
          job.company.toLowerCase().contains(query) ||
          job.location.toLowerCase().contains(query)
      ).toList();
    }

    emit(
      JobsLoaded(
        jobs: filteredJobs,
        totalCount: filteredJobs.length,
        applications: _userApplications,
      ),
    );
  }

  // ============================================================
  // 📍 6. تحميل طلبات التقديم للمستخدم
  // ============================================================
  // ============================================================
// 📍 6. تحميل طلبات التقديم للمستخدم
// ============================================================
  // ============================================================
// 📍 6. تحميل طلبات التقديم للمستخدم
// ============================================================

  Future<void> _onLoadUserApplications(
      LoadUserApplicationsEvent event,
      Emitter<JobState> emit,
      ) async {

    try {

      // ✅ جلب الطلبات من السيرفر
      final applications =
      await _jobRepository.fetchUserApplications(
        event.userId,
      );

      // ✅ تخزينها محلياً
      _userApplications = applications;

      // ✅ استخراج IDs الوظائف
      final appliedJobIds = applications
          .map((e) => e.jobId.toString())
          .toSet();

      // ✅ تحديث حالة الوظائف
      _allJobs = _allJobs.map((job) {

        return job.copyWith(
          isApplied: appliedJobIds.contains(
            job.id.toString(),
          ),
        );

      }).toList();

      // ✅ إرسال الحالتين معاً
      emit(
        JobsLoaded(
          jobs: _allJobs,
          totalCount: _allJobs.length,
          applications: _userApplications,
        ),
      );

      emit(
        UserApplicationsLoaded(
          applications: _userApplications,
        ),
      );

    } catch (e) {

      print(
        '❌ LoadUserApplications Error: $e',
      );

      emit(
        JobError(
          message:
          'Failed to load applications',
        ),
      );
    }
  }

  // ============================================================
  // 📍 7. تحديث حالة التقديم (للمدرب/الأدمن)
  // ============================================================
  Future<void> _onUpdateApplicationStatus(
      UpdateApplicationStatusEvent event,
      Emitter<JobState> emit,
      ) async {
    try {
      final success = await _jobRepository.updateApplicationStatus(
        applicationId: event.applicationId,
        newStatus: event.newStatus,
      );

      if (success) {
        // ✅ تحديث القائمة المحلية
        _userApplications = _userApplications.map((app) {
          if (app.id == event.applicationId) {
            return app.copyWith(status: _stringToStatus(event.newStatus));
          }
          return app;
        }).toList();

        emit(UserApplicationsLoaded(applications: _userApplications));
        emit(ApplicationStatusUpdated(
          message: 'Status updated to ${event.newStatus}',
          newStatus: _stringToStatus(event.newStatus),
        ));
      } else {
        emit(JobError(message: 'Failed to update status'));
      }
    } catch (e) {
      emit(JobError(message: 'Error updating status: ${e.toString()}'));
    }
  }

  // ============================================================
  // ============================================================
// 📍 8. تحديث قائمة طلبات التقديم
// ============================================================

  Future<void> _onRefreshUserApplications(
      RefreshUserApplicationsEvent event,
      Emitter<JobState> emit,
      ) async {

    try {

      final applications =
      await _jobRepository.refreshUserApplications(
        event.userId,
      );

      _userApplications = applications;

      // ✅ IDs
      final appliedJobIds = applications
          .map((e) => e.jobId.toString())
          .toSet();

      // ✅ تحديث الوظائف
      _allJobs = _allJobs.map((job) {

        return job.copyWith(
          isApplied:
          appliedJobIds.contains(
            job.id.toString(),
          ),
        );

      }).toList();

      emit(
        JobsLoaded(
          jobs: _allJobs,
          totalCount: _allJobs.length,
          applications: _userApplications,
        ),
      );

      emit(
        UserApplicationsLoaded(
          applications: _userApplications,
        ),
      );

    } catch (e) {

      emit(
        JobError(
          message:
          'Failed to refresh applications',
        ),
      );
    }
  }

  // ============================================================
  // 🔧 دوال مساعدة
  // ============================================================

  JobModel _getMockJob(String jobId) {
    return JobModel(
      id: jobId,
      title: 'Unknown Job',
      company: 'Unknown Company',
      companyLogo: '🏢',
      location: 'Unknown',
      type: 'Full-time',
      category: 'business',
      salary: 'N/A',
      description: '',
      requirements: [],
      postedDate: DateTime.now(),
      deadline: DateTime.now().add(const Duration(days: 30)),
      isRemote: false,
      experience: 'Entry-Level',
    );
  }

  ApplicationStatus _stringToStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return ApplicationStatus.approved;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.pending;
    }
  }
}