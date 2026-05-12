// 📄 lib/bloc/course/course_bloc.dart
// ============================================================
// 🧠 BLoC إدارة الكورسات - النسخة المصححة (تستخدم دوال موجودة)
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/course_models.dart';
import '../../models/user_model.dart';
import '../../repositories/course_repository.dart';
import 'course_event.dart';
import 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository _courseRepository;

  CourseBloc({required CourseRepository courseRepository})
      : _courseRepository = courseRepository,
        super(const CourseInitial()) {

    on<LoadRegisteredCoursesEvent>(_onLoadRegisteredCourses);
    on<LoadAvailableCoursesEvent>(_onLoadAvailableCourses);
    on<RegisterCourseEvent>(_onRegisterCourse);
    on<UnregisterCourseEvent>(_onUnregisterCourse);
    on<LoadCourseSessionsEvent>(_onLoadCourseSessions);
    on<LoadCourseContentEvent>(_onLoadCourseContent);
    on<ToggleLessonCompletionEvent>(_onToggleLessonCompletion);
    on<CalculateOverallProgressEvent>(_onCalculateOverallProgress);
  }

  // 📥 1. تحميل الكورسات المسجل فيها
  Future<void> _onLoadRegisteredCourses(
      LoadRegisteredCoursesEvent event,
      Emitter<CourseState> emit,
      ) async {

    emit(const CourseLoading());

    try {
      // ✅ نستخدم الدالة الموجودة مع فصل المنطق حسب النوع
      final courses = await _courseRepository.loadRegisteredCourses(event.userId);
      final progressData = await _courseRepository.calculateOverallProgress(event.userId);

      emit(RegisteredCoursesLoaded(
        registeredCourses: courses,
        overallProgress: progressData['overallProgress'] ?? 0.0,
        totalLessonsCompleted: progressData['completedLessons'] ?? 0,
        totalLessons: progressData['totalLessons'] ?? 0,
      ));

    } catch (e) {
      emit(CourseError(message: 'فشل جلب الكورسات: ${e.toString()}'));
    }
  }

  // 📥 2. تحميل الكورسات المتاحة (للمتدربين فقط)
  Future<void> _onLoadAvailableCourses(
      LoadAvailableCoursesEvent event,
      Emitter<CourseState> emit,
      ) async {

    emit(const CourseLoading());

    try {
      // ✅ نستخدم الدالة الموجودة مع فصل المنطق
      if (event.userType == UserType.trainee) {
        final courses = await _courseRepository.loadAvailableCourses(event.userId);
        emit(AvailableCoursesLoaded(availableCourses: courses));
      } else {
        // 👨‍🏫 المدرب ما يحتاج يشوف كورسات للتسجيل
        emit(AvailableCoursesLoaded(availableCourses: []));
      }

    } catch (e) {
      emit(CourseError(message: 'فشل جلب الكورسات المتاحة: ${e.toString()}'));
    }
  }

  // 📤 3. تسجيل كورس جديد (للمتدربين فقط)
  Future<void> _onRegisterCourse(
      RegisterCourseEvent event,
      Emitter<CourseState> emit,
      ) async {

    emit(const CourseLoading());

    try {
      // ✅ التسجيل متاح فقط للمتدربين
      if (event.userType != UserType.trainee) {
        emit(CourseError(message: 'Only trainees can register for courses'));
        return;
      }

      // ✅ نستخدم الدالة الموجودة
      final success = await _courseRepository.registerCourse(event.userId, event.course);

      if (success) {
        emit(CourseRegistered(
          message: 'Course registered successfully',
          registeredCourse: event.course,
        ));
        // ✅ نعيد تحميل القوائم
        add(LoadRegisteredCoursesEvent(userId: event.userId, userType: event.userType));
      } else {
        emit(CourseError(message: 'Failed to register course'));
      }

    } catch (e) {
      emit(CourseError(message: 'Error: ${e.toString()}'));
    }
  }

  // 🗑️ 4. إلغاء تسجيل كورس (للمتدربين فقط)
  Future<void> _onUnregisterCourse(
      UnregisterCourseEvent event,
      Emitter<CourseState> emit,
      ) async {

    emit(const CourseLoading());

    try {
      // ✅ الإلغاء متاح فقط للمتدربين
      if (event.userType != UserType.trainee) {
        emit(CourseError(message: 'Only trainees can unregister from courses'));
        return;
      }

      // ✅ نستخدم الدالة الموجودة
      final success = await _courseRepository.unregisterCourse(event.userId, event.courseId);

      if (success) {
        emit(CourseUnregistered(
          message: 'Course unregistered successfully',
          courseId: event.courseId,
        ));
        add(LoadRegisteredCoursesEvent(userId: event.userId, userType: event.userType));
      } else {
        emit(CourseError(message: 'Failed to unregister course'));
      }

    } catch (e) {
      emit(CourseError(message: 'Error: ${e.toString()}'));
    }
  }

  // 📚 5. جلب جلسات كورس معين (مشتركة)
  Future<void> _onLoadCourseSessions(
      LoadCourseSessionsEvent event,
      Emitter<CourseState> emit,
      ) async {
    try {
      final sessions = await _courseRepository.getCourseSessions(event.courseId);
      emit(CourseSessionsLoaded(sessions: sessions));
    } catch (e) {
      emit(CourseError(message: 'Failed to load sessions: ${e.toString()}'));
    }
  }

  // 📄 6. جلب محتوى كورس معين (مشترك)
  Future<void> _onLoadCourseContent(
      LoadCourseContentEvent event,
      Emitter<CourseState> emit,
      ) async {
    try {
      final contents = await _courseRepository.getCourseContent(event.courseId);
      emit(CourseContentLoaded(contents: contents));
    } catch (e) {
      emit(CourseError(message: 'Failed to load content: ${e.toString()}'));
    }
  }

  // 🔄 7. تبديل حالة إكمال درس (للمتدربين فقط)
  Future<void> _onToggleLessonCompletion(
      ToggleLessonCompletionEvent event,
      Emitter<CourseState> emit,
      ) async {
    try {
      if (event.userType != UserType.trainee) return;

      final success = await _courseRepository.toggleLessonCompletion(
        userId: event.userId,
        courseId: event.courseId,
        sessionId: event.sessionId,
        lessonId: event.lessonId,
        isCompleted: event.isCompleted,
      );

      if (success) {
        add(CalculateOverallProgressEvent(userId: event.userId, userType: event.userType));
        add(LoadRegisteredCoursesEvent(userId: event.userId, userType: event.userType));
      }
    } catch (e) {
      emit(CourseError(message: 'Error: ${e.toString()}'));
    }
  }

  // 📊 8. حساب التقدم الإجمالي (للمتدربين فقط)
  Future<void> _onCalculateOverallProgress(
      CalculateOverallProgressEvent event,
      Emitter<CourseState> emit,
      ) async {
    try {
      if (event.userType == UserType.trainee) {
        final progressData = await _courseRepository.calculateOverallProgress(event.userId);
        emit(ProgressUpdated(
          newOverallProgress: progressData['overallProgress'] ?? 0.0,
          completedLessons: progressData['completedLessons'] ?? 0,
        ));
      }
    } catch (e) {
      emit(CourseError(message: 'Error: ${e.toString()}'));
    }
  }
}