// 📄 lib/bloc/project/project_bloc.dart
// ============================================================
// 📁 الـ BLoC الرئيسي للمشاريع (Project Bloc)
// ============================================================
// الوظيفة: إدارة حالة المشاريع
// - تحميل المشاريع المميزة
// - تحميل المشاريع المطلوبة
// - تحميل مشاريع الطالب
// - تحميل تسليمات الطلاب
// - رفع مشروع جديد
// - تصحيح مشروع
// - إضافة مشروع مطلوب

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/project_models.dart';
import '../../repositories/project_repository.dart';

// ============================================================
// 🔷 الأحداث (Events)
// ============================================================

/// كلاس أساسي لكل الأحداث
abstract class ProjectEvent extends Equatable {
  const ProjectEvent();
  @override
  List<Object?> get props => [];
}

/// حدث تحميل المشاريع المميزة
class LoadFeaturedProjectsEvent extends ProjectEvent {
  const LoadFeaturedProjectsEvent();
}

/// حدث تحميل المشاريع المطلوبة (للكورس)
class LoadRequiredProjectsEvent extends ProjectEvent {
  final String courseId;
  final String trainerId;
  const LoadRequiredProjectsEvent({required this.courseId, required this.trainerId});
  @override
  List<Object?> get props => [courseId, trainerId];
}

/// حدث تحميل مشاريع الطالب الخاصة به
class LoadMyProjectsEvent extends ProjectEvent {
  final String studentId;
  const LoadMyProjectsEvent({required this.studentId});
  @override
  List<Object?> get props => [studentId];
}

/// حدث تحميل تسليمات الطلاب (للمدرب)
class LoadStudentSubmissionsEvent extends ProjectEvent {
  final String projectId;
  final String trainerId;
  const LoadStudentSubmissionsEvent({required this.projectId, required this.trainerId});
  @override
  List<Object?> get props => [projectId, trainerId];
}

/// حدث رفع مشروع جديد
class SubmitProjectEvent extends ProjectEvent {
  final String projectId;
  final String studentId;
  final String studentName;
  final String projectUrl;
  final String? description;
  final String? imageUrl;
  const SubmitProjectEvent({
    required this.projectId,
    required this.studentId,
    required this.studentName,
    required this.projectUrl,
    this.description,
    this.imageUrl,
  });
  @override
  List<Object?> get props => [projectId, studentId, studentName, projectUrl, description, imageUrl];
}

/// حدث تصحيح مشروع (للمدرب)
class GradeSubmissionEvent extends ProjectEvent {
  final String submissionId;
  final double grade;
  final String feedback;
  final String trainerId;
  const GradeSubmissionEvent({
    required this.submissionId,
    required this.grade,
    required this.feedback,
    required this.trainerId,
  });
  @override
  List<Object?> get props => [submissionId, grade, feedback, trainerId];
}

/// حدث إضافة مشروع مطلوب (للمدرب)
class AddRequiredProjectEvent extends ProjectEvent {
  final RequiredProject project;
  final String trainerId;
  const AddRequiredProjectEvent({required this.project, required this.trainerId});
  @override
  List<Object?> get props => [project, trainerId];
}

// ============================================================
// 🔷 الحالات (States)
// ============================================================

/// كلاس أساسي لكل الحالات
abstract class ProjectState extends Equatable {
  const ProjectState();
  @override
  List<Object?> get props => [];
}

/// الحالة الابتدائية
class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

/// حالة التحميل
class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

/// تم تحميل المشاريع المميزة بنجاح
class FeaturedProjectsLoaded extends ProjectState {
  final List<FeaturedProject> projects;
  const FeaturedProjectsLoaded({required this.projects});
  @override
  List<Object?> get props => [projects];
}

/// تم تحميل المشاريع المطلوبة بنجاح
class RequiredProjectsLoaded extends ProjectState {
  final List<RequiredProject> projects;
  const RequiredProjectsLoaded({required this.projects});
  @override
  List<Object?> get props => [projects];
}

/// تم تحميل مشاريع الطالب بنجاح
class MyProjectsLoaded extends ProjectState {
  final List<StudentProject> projects;
  const MyProjectsLoaded({required this.projects});
  @override
  List<Object?> get props => [projects];
}

/// تم تحميل تسليمات الطلاب بنجاح
class StudentSubmissionsLoaded extends ProjectState {
  final List<ProjectSubmission> submissions;
  const StudentSubmissionsLoaded({required this.submissions});
  @override
  List<Object?> get props => [submissions];
}

/// تم رفع المشروع بنجاح
class ProjectSubmitted extends ProjectState {
  final String message;
  const ProjectSubmitted({required this.message});
  @override
  List<Object?> get props => [message];
}

/// تم تصحيح المشروع بنجاح
class ProjectGraded extends ProjectState {
  final String message;
  const ProjectGraded({required this.message});
  @override
  List<Object?> get props => [message];
}

/// حالة الخطأ
class ProjectError extends ProjectState {
  final String message;
  const ProjectError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ============================================================
// 🔷 الـ BLoC الرئيسي
// ============================================================

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository _projectRepository;

  // 💾 تخزين مؤقت
  List<FeaturedProject> _cachedFeaturedProjects = [];
  List<RequiredProject> _cachedRequiredProjects = [];
  List<StudentProject> _cachedMyProjects = [];
  List<ProjectSubmission> _cachedSubmissions = [];

  ProjectBloc({required ProjectRepository projectRepository})
      : _projectRepository = projectRepository,
        super(const ProjectInitial()) {
    // 🎯 ربط الأحداث مع دوال المعالجة
    on<LoadFeaturedProjectsEvent>(_onLoadFeaturedProjects);
    on<LoadRequiredProjectsEvent>(_onLoadRequiredProjects);
    on<LoadMyProjectsEvent>(_onLoadMyProjects);
    on<LoadStudentSubmissionsEvent>(_onLoadStudentSubmissions);
    on<SubmitProjectEvent>(_onSubmitProject);
    on<GradeSubmissionEvent>(_onGradeSubmission);
    on<AddRequiredProjectEvent>(_onAddRequiredProject);
  }

  // ============================================================
  // 📍 1. معالج تحميل المشاريع المميزة
  // ============================================================
  Future<void> _onLoadFeaturedProjects(
      LoadFeaturedProjectsEvent event,
      Emitter<ProjectState> emit,
      ) async {
    // 1️⃣ إرسال حالة التحميل
    emit(const ProjectLoading());

    try {
      // 2️⃣ جلب البيانات من الـ Repository
      final projects = await _projectRepository.loadFeaturedProjects();
      _cachedFeaturedProjects = projects;

      // 3️⃣ إرسال حالة النجاح مع البيانات
      emit(FeaturedProjectsLoaded(projects: projects));
    } catch (e) {
      // ❌ في حالة الخطأ
      emit(ProjectError(message: 'Failed to load featured projects: ${e.toString()}'));
    }
  }

  // ============================================================
  // 📍 2. معالج تحميل المشاريع المطلوبة
  // ============================================================
  Future<void> _onLoadRequiredProjects(
      LoadRequiredProjectsEvent event,
      Emitter<ProjectState> emit,
      ) async {
    emit(const ProjectLoading());

    try {
      final projects = await _projectRepository.loadRequiredProjects(event.courseId);
      _cachedRequiredProjects = projects;
      emit(RequiredProjectsLoaded(projects: projects));
    } catch (e) {
      emit(ProjectError(message: 'Failed to load required projects: ${e.toString()}'));
    }
  }

  // ============================================================
  // 📍 3. معالج تحميل مشاريع الطالب
  // ============================================================
  Future<void> _onLoadMyProjects(
      LoadMyProjectsEvent event,
      Emitter<ProjectState> emit,
      ) async {
    emit(const ProjectLoading());

    try {
      final projects = await _projectRepository.loadMyProjects(event.studentId);
      _cachedMyProjects = projects;
      emit(MyProjectsLoaded(projects: projects));
    } catch (e) {
      emit(ProjectError(message: 'Failed to load your projects: ${e.toString()}'));
    }
  }

  // ============================================================
  // 📍 4. معالج تحميل تسليمات الطلاب
  // ============================================================
  Future<void> _onLoadStudentSubmissions(
      LoadStudentSubmissionsEvent event,
      Emitter<ProjectState> emit,
      ) async {
    emit(const ProjectLoading());

    try {
      final submissions = await _projectRepository.loadStudentSubmissions(event.projectId);
      _cachedSubmissions = submissions;
      emit(StudentSubmissionsLoaded(submissions: submissions));
    } catch (e) {
      emit(ProjectError(message: 'Failed to load student submissions: ${e.toString()}'));
    }
  }

  // ============================================================
  // 📍 5. معالج رفع مشروع جديد
  // ============================================================
  Future<void> _onSubmitProject(
      SubmitProjectEvent event,
      Emitter<ProjectState> emit,
      ) async {
    emit(const ProjectLoading());

    try {
      final success = await _projectRepository.submitProject(
        projectId: event.projectId,
        studentId: event.studentId,
        projectUrl: event.projectUrl,
        description: event.description,
        imageUrl: event.imageUrl,
      );

      if (success) {
        emit(ProjectSubmitted(message: 'Project submitted successfully!'));
        // ✅ إعادة تحميل المشاريع بعد الرفع
        add(LoadMyProjectsEvent(studentId: event.studentId));
      } else {
        emit(ProjectError(message: 'Failed to submit project'));
      }
    } catch (e) {
      emit(ProjectError(message: 'Error submitting project: ${e.toString()}'));
    }
  }

  // ============================================================
  // 📍 6. معالج تصحيح مشروع (للمدرب)
  // ============================================================
  Future<void> _onGradeSubmission(
      GradeSubmissionEvent event,
      Emitter<ProjectState> emit,
      ) async {
    emit(const ProjectLoading());

    try {
      final success = await _projectRepository.gradeSubmission(
        submissionId: event.submissionId,
        grade: event.grade,
        feedback: event.feedback,
      );

      if (success) {
        emit(ProjectGraded(message: 'Project graded successfully!'));
        // ✅ إعادة تحميل مشاريع الطالب بعد التصحيح
        add(LoadMyProjectsEvent(studentId: event.trainerId)); // سيتم تعديل هذا حسب الحاجة
      } else {
        emit(ProjectError(message: 'Failed to grade project'));
      }
    } catch (e) {
      emit(ProjectError(message: 'Error grading project: ${e.toString()}'));
    }
  }

  // ============================================================
  // 📍 7. معالج إضافة مشروع مطلوب (للمدرب)
  // ============================================================
  Future<void> _onAddRequiredProject(
      AddRequiredProjectEvent event,
      Emitter<ProjectState> emit,
      ) async {
    emit(const ProjectLoading());

    try {
      // TODO: إضافة API call لإضافة مشروع مطلوب
      // final success = await _projectRepository.addRequiredProject(event.project);
      // if (success) { ... }

      emit(ProjectSubmitted(message: 'Required project added successfully!'));
    } catch (e) {
      emit(ProjectError(message: 'Failed to add required project: ${e.toString()}'));
    }
  }
}