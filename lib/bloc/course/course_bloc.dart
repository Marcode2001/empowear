// 📄 lib/bloc/course/course_bloc.dart
// ============================================================
// 🧠 BLoC إدارة الكورسات - جميع المعرفات String للواجهة
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/course_models.dart';
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

  // 📥 تحميل الكورسات المسجل فيها
  Future<void> _onLoadRegisteredCourses(
      LoadRegisteredCoursesEvent event,
      Emitter<CourseState> emit,
      ) async {
    emit(const CourseLoading());
    try {
      final courses = await _courseRepository.loadRegisteredCourses(event.userId);
      final progressData = await _courseRepository.calculateOverallProgress(event.userId);
      emit(RegisteredCoursesLoaded(
        registeredCourses: courses,
        overallProgress: progressData['overallProgress'],
        totalLessonsCompleted: progressData['completedLessons'],
        totalLessons: progressData['totalLessons'],
      ));
    } catch (e) {
      emit(CourseError(message: 'فشل جلب الكورسات: ${e.toString()}'));
    }
  }

  // 📥 تحميل الكورسات المتاحة
  Future<void> _onLoadAvailableCourses(
      LoadAvailableCoursesEvent event,
      Emitter<CourseState> emit,
      ) async {
    emit(const CourseLoading());
    try {
      final courses = await _courseRepository.loadAvailableCourses(event.userId);
      emit(AvailableCoursesLoaded(availableCourses: courses));
    } catch (e) {
      emit(CourseError(message: 'فشل جلب الكورسات المتاحة: ${e.toString()}'));
    }
  }

  // 📤 تسجيل كورس جديد
  // 📤 تسجيل كورس جديد
  Future<void> _onRegisterCourse(
      RegisterCourseEvent event,
      Emitter<CourseState> emit,
      ) async {
    emit(const CourseLoading());
    try {
      final success = await _courseRepository.registerCourse(event.userId, event.course);
      if (success) {
        emit(CourseRegistered(
          message: 'Course registered successfully',
          registeredCourse: event.course,
        ));
        // ✅ أعد تحميل الكورسات المسجلة لتحديث الواجهة
        add(LoadRegisteredCoursesEvent(userId: event.userId));
      } else {
        emit(CourseError(message: 'Failed to register course'));
      }
    } catch (e) {
      emit(CourseError(message: 'Error: ${e.toString()}'));
    }
  }

  // 🗑️ إلغاء تسجيل كورس
  Future<void> _onUnregisterCourse(
      UnregisterCourseEvent event,
      Emitter<CourseState> emit,
      ) async {
    emit(const CourseLoading());
    try {
      final success = await _courseRepository.unregisterCourse(event.userId, event.courseId);
      if (success) {
        emit(CourseUnregistered(
          message: 'Course unregistered successfully',
          courseId: event.courseId,
        ));
        add(LoadRegisteredCoursesEvent(userId: event.userId));
      } else {
        emit(CourseError(message: 'Failed to unregister course'));
      }
    } catch (e) {
      emit(CourseError(message: 'Error: ${e.toString()}'));
    }
  }

  // 📚 جلب جلسات كورس معين
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

  // 📄 جلب محتوى كورس معين
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

  // 🔄 تبديل حالة إكمال درس
  Future<void> _onToggleLessonCompletion(
      ToggleLessonCompletionEvent event,
      Emitter<CourseState> emit,
      ) async {
    try {
      final success = await _courseRepository.toggleLessonCompletion(
        userId: event.userId,
        courseId: event.courseId,
        sessionId: event.sessionId,
        lessonId: event.lessonId,
        isCompleted: event.isCompleted,
      );
      if (success) {
        add(CalculateOverallProgressEvent(userId: event.userId));
        add(LoadRegisteredCoursesEvent(userId: event.userId));
      }
    } catch (e) {
      emit(CourseError(message: 'Error: ${e.toString()}'));
    }
  }

  // 📊 حساب التقدم الإجمالي
  Future<void> _onCalculateOverallProgress(
      CalculateOverallProgressEvent event,
      Emitter<CourseState> emit,
      ) async {
    try {
      final progressData = await _courseRepository.calculateOverallProgress(event.userId);
      emit(ProgressUpdated(
        newOverallProgress: progressData['overallProgress'],
        completedLessons: progressData['completedLessons'],
      ));
    } catch (e) {
      emit(CourseError(message: 'Error: ${e.toString()}'));
    }
  }
}