// 📄 lib/bloc/course/course_event.dart
// ============================================================
// 🎯 أحداث الكورسات - مع إضافة UserType لتحديد الصلاحيات
// ============================================================

import 'package:equatable/equatable.dart';
import '../../models/course_models.dart';
import '../../models/user_model.dart';  // ✅ ضروري للوصول لـ UserType

abstract class CourseEvent extends Equatable {
  const CourseEvent();
  @override
  List<Object?> get props => [];
}

// 📥 تحميل الكورسات المسجل فيها (يحتاج معرفة نوع المستخدم)
class LoadRegisteredCoursesEvent extends CourseEvent {
  final String userId;
  final UserType userType;  // ✅ أضيفي هذا الحقل لتحديد الصلاحيات

  const LoadRegisteredCoursesEvent({required this.userId, required this.userType});

  @override
  List<Object?> get props => [userId, userType];
}

// 📥 تحميل الكورسات المتاحة للتسجيل (للمتدربين فقط)
class LoadAvailableCoursesEvent extends CourseEvent {
  final String userId;
  final UserType userType;  // ✅ أضيفي هذا الحقل
  const LoadAvailableCoursesEvent({required this.userId, required this.userType});

  @override
  List<Object?> get props => [userId, userType];
}

// 📤 تسجيل كورس جديد (للمتدربين فقط)
class RegisterCourseEvent extends CourseEvent {
  final CourseItem course;
  final String userId;
  final UserType userType;  // ✅ أضيفي هذا الحقل
  const RegisterCourseEvent({required this.course, required this.userId, required this.userType});

  @override
  List<Object?> get props => [course, userId, userType];
}

// 🗑️ إلغاء تسجيل كورس (للمتدربين فقط)
class UnregisterCourseEvent extends CourseEvent {
  final String courseId;
  final String userId;
  final UserType userType;  // ✅ أضيفي هذا الحقل
  const UnregisterCourseEvent({required this.courseId, required this.userId, required this.userType});

  @override
  List<Object?> get props => [courseId, userId, userType];
}

// 📚 جلب جلسات كورس معين (مشترك للجميع - ما يحتاج UserType)
class LoadCourseSessionsEvent extends CourseEvent {
  final String courseId;
  const LoadCourseSessionsEvent({required this.courseId});
  @override
  List<Object?> get props => [courseId];
}

// 📄 جلب محتوى كورس معين (مشترك للجميع - ما يحتاج UserType)
class LoadCourseContentEvent extends CourseEvent {
  final String courseId;
  const LoadCourseContentEvent({required this.courseId});
  @override
  List<Object?> get props => [courseId];
}

// 🔄 تبديل حالة إكمال درس (للمتدربين فقط)
class ToggleLessonCompletionEvent extends CourseEvent {
  final String courseId;
  final String userId;
  final String sessionId;
  final String lessonId;
  final bool isCompleted;
  final UserType userType;  // ✅ أضيفي هذا الحقل
  const ToggleLessonCompletionEvent({
    required this.courseId,
    required this.userId,
    required this.sessionId,
    required this.lessonId,
    required this.isCompleted,
    required this.userType,
  });
  @override
  List<Object?> get props => [courseId, userId, sessionId, lessonId, isCompleted, userType];
}

// 📊 حساب التقدم الإجمالي (للمتدربين فقط)
class CalculateOverallProgressEvent extends CourseEvent {
  final String userId;
  final UserType userType;  // ✅ أضيفي هذا الحقل
  const CalculateOverallProgressEvent({required this.userId, required this.userType});
  @override
  List<Object?> get props => [userId, userType];
}