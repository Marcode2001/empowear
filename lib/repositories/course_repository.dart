// 📄 lib/repositories/course_repository.dart
// ============================================================
// 🔗 مستودع الكورسات - يتواصل مع الـ API ويحول البيانات
// ✅ الإصدار النهائي مع دالة ربط المحتوى بالجلسات
// ⚠️ تم إصلاح خطأ Syntax بدون تغيير أي منطق للمتدرب
// ============================================================

import '../models/course_models.dart';
import '../services/api_service.dart';

class CourseRepository {

  // ============================================================
  // 📥 1. جلب الكورسات المسجلة للطالب
  // ============================================================
  Future<List<CourseItem>> loadRegisteredCourses(String userId) async {
    try {
      print('📚 [REPO] جلب الكورسات المسجلة للمستخدم: $userId');

      final response = await ApiService.get(
        endpoint: 'course/trainee-my-courses/',
        requireAuth: true,
      );

      if (response['success']) {
        final rawData = response['data'] ?? response;
        final List<dynamic> data = rawData is List ? rawData : [];
        print('✅ [REPO] تم جلب ${data.length} كورس مسجل');
        return data.map((json) => CourseItem.fromJson(json)).toList();
      }

      print('⚠️ [REPO] لا توجد كورسات مسجلة');
      return [];
    } catch (e) {
      print('❌ [REPO] خطأ في جلب الكورسات المسجلة: $e');
      return [];
    }
  }

  // ============================================================
  // 📥 2. جلب الكورسات المتاحة للتسجيل
  // ============================================================
  Future<List<CourseItem>> loadAvailableCourses(String userId) async {
    try {
      print('📚 [REPO] جلب الكورسات المتاحة للمستخدم: $userId');

      final response = await ApiService.get(
        endpoint: 'course/trainee-all-courses/',
        requireAuth: true,
      );

      if (response['success']) {
        final rawData = response['data'] ?? response;
        final List<dynamic> data = rawData is List ? rawData : [];
        print('✅ [REPO] تم جلب ${data.length} كورس متاح');
        return data.map((json) => CourseItem.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('❌ [REPO] خطأ في جلب الكورسات المتاحة: $e');
      return [];
    }
  }

  // ============================================================
  // 📤 3. تسجيل كورس جديد
  // ============================================================
  Future<bool> registerCourse(String userId, CourseItem course) async {
    try {
      final courseIdInt = int.tryParse(course.id) ?? 0;

      final response = await ApiService.post(
        endpoint: 'enrollment-request/trainee-create/',
        data: {'course': courseIdInt},
        requireAuth: true,
      );

      return response['success'] == true;
    } catch (e) {
      print('❌ [REPO] خطأ في تسجيل الكورس: $e');
      return false;
    }
  }

  // ============================================================
  // 🗑️ 4. إلغاء تسجيل كورس
  // ============================================================
  Future<bool> unregisterCourse(String userId, String courseId) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;

      final response = await ApiService.delete(
        endpoint: 'enrollment-request/trainee-delete/$courseIdInt/',
        requireAuth: true,
      );

      return response['success'] == true;
    } catch (e) {
      print('❌ [REPO] خطأ في إلغاء تسجيل الكورس: $e');
      return false;
    }
  }

  // ============================================================
  // 📚 5. جلب جلسات كورس معين
  // ============================================================
  Future<List<Session>> getCourseSessions(String courseId) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;

      final response = await ApiService.get(
        endpoint: 'course-session/trainee-search-by-course-id/$courseIdInt/',
        requireAuth: true,
      );

      if (response['success']) {
        final rawData = response['data'] ?? response;
        final List<dynamic> data = rawData is List ? rawData : [];
        return data.map((json) => Session.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('❌ [REPO] خطأ في جلب الجلسات: $e');
      return [];
    }
  }

  // ============================================================
  // 📄 6. جلب محتوى كورس معين
  // ============================================================
  Future<List<CourseContent>> getCourseContent(String courseId) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;

      final response = await ApiService.get(
        endpoint: 'course-content/trainee-search-by-course-id/$courseIdInt/',
        requireAuth: true,
      );

      if (response['success']) {
        final rawData = response['data'] ?? response;
        final List<dynamic> data = rawData is List ? rawData : [];

        // 🟡 Debug فقط بدون تأثير على المنطق
        for (var i = 0; i < data.length; i++) {
          print('📄 ${data[i]['title']} - session_order: ${data[i]['session_order']}');
        }

        return data.map((json) => CourseContent.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('❌ [REPO] خطأ في جلب المحتوى: $e');
      return [];
    }
  }

  // ============================================================
  // ⭐ 7. ربط الجلسات مع المحتوى (Core Function)
  // ============================================================
  Future<List<Session>> getCourseSessionsWithContent(String courseId) async {
    try {
      final sessions = await getCourseSessions(courseId);
      final contents = await getCourseContent(courseId);

      // 🟢 إذا ما في جلسات
      if (sessions.isEmpty) return [];

      // 🟢 إنشاء Map للجلسات حسب order
      final Map<int, Session> sessionMap = {};

      for (var session in sessions) {
        if (session.sessionOrder != null) {
          sessionMap[session.sessionOrder!] = session;
        }
      }

      // 🟢 ربط المحتوى
      for (var content in contents) {
        final session = sessionMap[content.sessionOrder];

        if (session != null) {
          final updatedContents = List<CourseContent>.from(session.contents)
            ..add(content);

          sessionMap[content.sessionOrder] = Session(
            id: session.id,
            course: session.course,
            courseTitle: session.courseTitle,
            title: session.title,
            description: session.description,
            sessionOrder: session.sessionOrder,
            contents: updatedContents,
          );
        }
      }

      // 🟢 ترتيب وإرجاع
      final result = sessionMap.values.toList()
        ..sort((a, b) => (a.sessionOrder ?? 0).compareTo(b.sessionOrder ?? 0));

      return result;

    } catch (e) {
      print('❌ [REPO] خطأ في الربط: $e');
      return [];
    }
  }

  // ============================================================
// 📄 جلب محتوى كورس للمدرب
// ============================================================
  Future<List<CourseContent>> getTrainerCourseContent(String courseId) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;

      final response = await ApiService.get(
        endpoint: 'course-content/trainer-search-by-course-id/$courseIdInt/',
        requireAuth: true,
      );

      if (response['success']) {
        final rawData = response['data'] ?? response;
        final List<dynamic> data = rawData is List ? rawData : [];

        return data.map((json) => CourseContent.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('❌ [REPO] خطأ في جلب محتوى المدرب: $e');
      return [];
    }
  }

  // ============================================================
// 📄 جلب محتوى جلسة معينة للمدرب
// ============================================================
  Future<List<CourseContent>> getTrainerSessionContent(
      String courseId,
      int sessionOrder,
      ) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;

      final response = await ApiService.get(
        endpoint:
        'course-content/trainer-search-by-course-id-and-session-order/$courseIdInt/$sessionOrder/',
        requireAuth: true,
      );

      if (response['success']) {
        final rawData = response['data'] ?? response;
        final List<dynamic> data = rawData is List ? rawData : [];

        return data.map((json) => CourseContent.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('❌ [REPO] خطأ في جلب محتوى الجلسة: $e');
      return [];
    }
  }

  // ============================================================
// ⭐ ربط جلسات المدرب مع المحتوى
// ============================================================
  Future<List<Session>> getTrainerSessionsWithContent(
      String courseId,
      ) async {
    try {
      final sessions = await getTrainerCourseSessions(courseId);

      if (sessions.isEmpty) return [];

      List<Session> updatedSessions = [];

      for (var session in sessions) {
        final contents = await getTrainerSessionContent(
          courseId,
          session.sessionOrder ?? 0,
        );

        updatedSessions.add(
          Session(
            id: session.id,
            course: session.course,
            courseTitle: session.courseTitle,
            title: session.title,
            description: session.description,
            sessionOrder: session.sessionOrder,
            contents: contents,
          ),
        );
      }

      return updatedSessions;
    } catch (e) {
      print('❌ [REPO] خطأ بربط جلسات المدرب: $e');
      return [];
    }
  }

  // ============================================================
// 📚 جلب جلسات كورس للمدرب
// ============================================================
  Future<List<Session>> getTrainerCourseSessions(String courseId) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;

      final response = await ApiService.get(
        endpoint: 'course-session/trainer-search-by-course-id/$courseIdInt/',
        requireAuth: true,
      );

      if (response['success']) {
        final rawData = response['data'] ?? response;
        final List<dynamic> data = rawData is List ? rawData : [];

        return data.map((json) => Session.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('❌ [REPO] خطأ في جلب جلسات المدرب: $e');
      return [];
    }
  }

  // ============================================================
  // 📊 دوال وهمية (لا تؤثر على النظام)
  // ============================================================
  Future<bool> updateProgress(String userId, String courseId, int progress) async => true;

  Future<bool> toggleLessonCompletion({
    required String userId,
    required String courseId,
    required String sessionId,
    required String lessonId,
    required bool isCompleted,
  }) async => true;

  Future<Map<String, dynamic>> calculateOverallProgress(String userId) async => {
    'overallProgress': 0.0,
    'completedLessons': 0,
    'totalLessons': 0
  };

  Future<CourseDetail?> getCourseDetail(String courseId) async {
    try {
      final sessions = await getCourseSessionsWithContent(courseId);
      if (sessions.isEmpty) return null;

      return CourseDetail(
        id: int.tryParse(courseId) ?? 0,
        title: sessions.first.courseTitle,
        description: '',
        sessions: sessions,
      );
    } catch (e) {
      print('❌ [REPO] خطأ في التفاصيل: $e');
      return null;
    }
  }

  Future<List<CourseItem>> loadTrainerCourses(String trainerId) async {
    final response = await ApiService.get(
      endpoint: 'course/trainer-my-courses/',
      requireAuth: true,
    );

    if (response['success']) {
      final List data = response['data'];
      return data.map((e) => CourseItem.fromJson(e)).toList();
    }

    return [];
  }
}

// ============================================================
// 📦 CourseDetail Model
// ============================================================
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
}