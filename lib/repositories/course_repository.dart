// 📄 lib/repositories/course_repository.dart
// ============================================================
// 🔗 مستودع الكورسات - يتواصل مع الـ API ويحول البيانات
// ============================================================

import '../models/course_models.dart';
import '../services/api_service.dart';

class CourseRepository {

  // ============================================================
  // 📥 1. جلب الكورسات المسجلة للطالب
  // ============================================================
  // تستدعي: GET /api/course/trainee-my-courses/
  Future<List<CourseItem>> loadRegisteredCourses(String userId) async {
    try {
      // نرسل طلب GET إلى الـ endpoint الخاص بالكورسات المسجلة
      final response = await ApiService.get(
        endpoint: 'course/trainee-my-courses/',  // من ملف Postman
        requireAuth: true,  // نحتاج توكن المصادقة
      );

      // إذا نجح الطلب
      if (response['success']) {
        // نستخرج البيانات (قد تكون في 'data' أو مباشرة)
        final rawData = response['data'] ?? response;
        // نحولها إلى قائمة
        final List<dynamic> data = rawData is List ? rawData : [];
        // نحول كل عنصر JSON إلى CourseItem
        return data.map((json) => CourseItem.fromJson(json)).toList();
      }
      return [];  // في حالة الفشل نرجع قائمة فاضية
    } catch (e) {
      print('❌ خطأ في جلب الكورسات المسجلة: $e');
      return [];
    }
  }

  // ============================================================
  // 📥 2. جلب الكورسات المتاحة للتسجيل
  // ============================================================
  // تستدعي: GET /api/course/trainee-all-courses
  Future<List<CourseItem>> loadAvailableCourses(String userId) async {
    try {
      final response = await ApiService.get(
        endpoint: 'course/trainee-all-courses',  // من ملف Postman
        requireAuth: true,
      );

      if (response['success']) {
        final rawData = response['data'] ?? response;
        final List<dynamic> data = rawData is List ? rawData : [];
        return data.map((json) => CourseItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ خطأ في جلب الكورسات المتاحة: $e');
      return [];
    }
  }

  // ============================================================
  // 📤 3. تسجيل كورس جديد (إرسال طلب تسجيل)
  // ============================================================
  // تستدعي: POST /api/enrollment-request/trainee-create/
  Future<bool> registerCourse(String userId, CourseItem course) async {
    try {
      // نحول معرف الكورس من String إلى int
      final courseIdInt = int.tryParse(course.id) ?? 0;

      // نرسل طلب POST مع معرف الكورس فقط
      final response = await ApiService.post(
        endpoint: 'enrollment-request/trainee-create/',
        data: {'course': courseIdInt},
        requireAuth: true,
      );
      return response['success'] == true;
    } catch (e) {
      print('❌ خطأ في تسجيل الكورس: $e');
      return false;
    }
  }

  // ============================================================
  // 🗑️ 4. إلغاء تسجيل كورس
  // ============================================================
  // تستدعي: DELETE /api/enrollment-request/trainee-delete/{id}/
  Future<bool> unregisterCourse(String userId, String courseId) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;

      final response = await ApiService.delete(
        endpoint: 'enrollment-request/trainee-delete/$courseIdInt/',
        requireAuth: true,
      );
      return response['success'] == true;
    } catch (e) {
      print('❌ خطأ في إلغاء تسجيل الكورس: $e');
      return false;
    }
  }

  // ============================================================
  // 📚 5. جلب جلسات كورس معين
  // ============================================================
  // تستدعي: GET /api/course-session/trainee-search-by-course-id/{id}/
  Future<List<Session>> getCourseSessions(String courseId) async {
    try {
      // نحول معرف الكورس من String إلى int
      final courseIdInt = int.tryParse(courseId) ?? 0;

      // نرسل طلب GET إلى endpoint الجلسات
      final response = await ApiService.get(
        endpoint: 'course-session/trainee-search-by-course-id/$courseIdInt/',
        requireAuth: true,
      );

      if (response['success']) {
        final rawData = response['data'] ?? response;
        final List<dynamic> data = rawData is List ? rawData : [];
        // نحول كل عنصر JSON إلى Session
        return data.map((json) => Session.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ خطأ في جلب الجلسات: $e');
      return [];
    }
  }

  // ============================================================
  // 📄 6. جلب محتوى كورس معين (كل الدروس)
  // ============================================================
  // تستدعي: GET /api/course-content/trainee-search-by-course-id/{id}/
  Future<List<CourseContent>> getCourseContent(String courseId) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;

      // 🔴 هذا هو الـ endpoint الذي تبحث عنه
      final response = await ApiService.get(
        endpoint: 'course-content/trainee-search-by-course-id/$courseIdInt/',
        requireAuth: true,
      );

      if (response['success']) {
        final rawData = response['data'] ?? response;
        final List<dynamic> data = rawData is List ? rawData : [];

        // 🔍 للتصحيح: نطبع عدد العناصر التي جائت
        print('📚 عدد عناصر المحتوى المستلمة: ${data.length}');

        // نحول كل عنصر JSON إلى CourseContent
        return data.map((json) => CourseContent.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ خطأ في جلب محتوى الكورس: $e');
      return [];
    }
  }

  // ============================================================
  // 📊 دوال مساعدة (مؤقتة للتوافق)
  // ============================================================

  Future<bool> updateProgress(String userId, String courseId, int progress) async => true;

  Future<bool> toggleLessonCompletion({
    required String userId,
    required String courseId,
    required String sessionId,
    required String lessonId,
    required bool isCompleted,
  }) async => true;

  Future<Map<String, dynamic>> calculateOverallProgress(String userId) async {
    return {'overallProgress': 0.0, 'completedLessons': 0, 'totalLessons': 0};
  }

  Future<CourseDetail?> getCourseDetail(String courseId) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;
      final response = await ApiService.get(
        endpoint: 'course-content/trainee-search-by-course-id/$courseIdInt/',
        requireAuth: true,
      );
      if (response['success']) {
        final rawData = response['data'] ?? response;
        return CourseDetail.fromJson(rawData);
      }
      return null;
    } catch (e) {
      print('❌ خطأ في جلب تفاصيل الكورس: $e');
      return null;
    }
  }
}

// نموذج مؤقت لتفاصيل الكورس
class CourseDetail {
  final int id;
  final String title;
  final String description;
  final List<Session> sessions;

  const CourseDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.sessions,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    final List<dynamic> sessionsData = json['sessions'] ?? json['course_sessions'] ?? [];
    return CourseDetail(
      id: json['id'] ?? json['course_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      sessions: sessionsData.map((s) => Session.fromJson(s)).toList(),
    );
  }
}