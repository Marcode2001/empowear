// 📄 lib/bloc/course/course_event.dart
// ============================================================
// 🎯 أحداث الكورسات - جميع المعرفات من نوع String للواجهة
// ============================================================

import 'package:equatable/equatable.dart';
import '../../models/course_models.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();
  @override
  List<Object?> get props => [];
}

// 📥 تحميل الكورسات المسجل فيها الطالب
class LoadRegisteredCoursesEvent extends CourseEvent {
  final String userId;  // ✅ String للواجهة
  const LoadRegisteredCoursesEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}

// 📥 تحميل الكورسات المتاحة للتسجيل
class LoadAvailableCoursesEvent extends CourseEvent {
  final String userId;
  const LoadAvailableCoursesEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}

// 📤 تسجيل كورس جديد
class RegisterCourseEvent extends CourseEvent {
  final CourseItem course;
  final String userId;
  const RegisterCourseEvent({required this.course, required this.userId});
  @override
  List<Object?> get props => [course, userId];
}

// 🗑️ إلغاء تسجيل كورس
class UnregisterCourseEvent extends CourseEvent {
  final String courseId;  // ✅ String للواجهة
  final String userId;
  const UnregisterCourseEvent({required this.courseId, required this.userId});
  @override
  List<Object?> get props => [courseId, userId];
}

// 📚 جلب جلسات كورس معين
class LoadCourseSessionsEvent extends CourseEvent {
  final String courseId;  // ✅ String
  const LoadCourseSessionsEvent({required this.courseId});
  @override
  List<Object?> get props => [courseId];
}

// 📄 جلب محتوى كورس معين
class LoadCourseContentEvent extends CourseEvent {
  final String courseId;  // ✅ String
  const LoadCourseContentEvent({required this.courseId});
  @override
  List<Object?> get props => [courseId];
}

// 🔄 تبديل حالة إكمال درس
class ToggleLessonCompletionEvent extends CourseEvent {
  final String courseId;
  final String userId;
  final String sessionId;
  final String lessonId;
  final bool isCompleted;
  const ToggleLessonCompletionEvent({
    required this.courseId,
    required this.userId,
    required this.sessionId,
    required this.lessonId,
    required this.isCompleted,
  });
  @override
  List<Object?> get props => [courseId, userId, sessionId, lessonId, isCompleted];
}

// 📊 حساب التقدم الإجمالي
class CalculateOverallProgressEvent extends CourseEvent {
  final String userId;
  const CalculateOverallProgressEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}