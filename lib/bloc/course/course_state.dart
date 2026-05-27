// 📄 lib/bloc/course/course_state.dart
// ============================================================
// 🎯 حالات الكورسات - جميع المعرفات من نوع String للواجهة
// ============================================================

import 'package:equatable/equatable.dart';
import '../../models/course_models.dart';

abstract class CourseState extends Equatable {
  const CourseState();
  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {
  const CourseInitial();
}

class CourseLoading extends CourseState {
  const CourseLoading();
}

// ✅ تحميل بدون حذف البيانات القديمة
class CourseRefreshing extends CourseState {
  final List<CourseItem> currentCourses;

  const CourseRefreshing({
    required this.currentCourses,
  });

  @override
  List<Object?> get props => [currentCourses];
}

// ✅ الكورسات المسجل فيها
class RegisteredCoursesLoaded extends CourseState {
  final List<CourseItem> registeredCourses;
  final double overallProgress;
  final int totalLessonsCompleted;
  final int totalLessons;
  const RegisteredCoursesLoaded({
    required this.registeredCourses,
    required this.overallProgress,
    required this.totalLessonsCompleted,
    required this.totalLessons,
  });
  @override
  List<Object?> get props => [registeredCourses, overallProgress, totalLessonsCompleted, totalLessons];
}

// ✅ الكورسات المتاحة
class AvailableCoursesLoaded extends CourseState {
  final List<CourseItem> availableCourses;
  const AvailableCoursesLoaded({required this.availableCourses});
  @override
  List<Object?> get props => [availableCourses];
}

// ✅ جلسات كورس معين
class CourseSessionsLoaded extends CourseState {
  final List<Session> sessions;
  const CourseSessionsLoaded({required this.sessions});
  @override
  List<Object?> get props => [sessions];
}

// ✅ محتوى كورس معين
class CourseContentLoaded extends CourseState {
  final List<CourseContent> contents;
  const CourseContentLoaded({required this.contents});
  @override
  List<Object?> get props => [contents];
}

// ✅ نجاح التسجيل
class CourseRegistered extends CourseState {
  final String message;
  final CourseItem registeredCourse;
  const CourseRegistered({required this.message, required this.registeredCourse});
  @override
  List<Object?> get props => [message, registeredCourse];
}

// ✅ نجاح إلغاء التسجيل
class CourseUnregistered extends CourseState {
  final String message;
  final String courseId;  // ✅ String للواجهة
  const CourseUnregistered({required this.message, required this.courseId});
  @override
  List<Object?> get props => [message, courseId];
}

// ✅ تحديث التقدم
class ProgressUpdated extends CourseState {
  final double newOverallProgress;
  final int completedLessons;
  const ProgressUpdated({required this.newOverallProgress, required this.completedLessons});
  @override
  List<Object?> get props => [newOverallProgress, completedLessons];
}

// ❌ خطأ
class CourseError extends CourseState {
  final String message;
  const CourseError({required this.message});
  @override
  List<Object?> get props => [message];
}