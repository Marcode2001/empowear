// 📄 lib/repositories/course_repository.dart
// ============================================================
// 🔗 مستودع الكورسات - يتواصل مع الـ API ويحول البيانات
// ✅ الإصدار النهائي مع دالة ربط المحتوى بالجلسات
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
  // تستدعي: GET /api/course/trainee-all-courses
  Future<List<CourseItem>> loadAvailableCourses(String userId) async {
    try {
      print('📚 [REPO] جلب الكورسات المتاحة للمستخدم: $userId');

      final response = await ApiService.get(
        endpoint: 'course/trainee-all-courses',
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
  // 📤 3. تسجيل كورس جديد (إرسال طلب تسجيل)
  // ============================================================
  // تستدعي: POST /api/enrollment-request/trainee-create/
  Future<bool> registerCourse(String userId, CourseItem course) async {
    try {
      final courseIdInt = int.tryParse(course.id) ?? 0;
      print('📤 [REPO] تسجيل كورس جديد - الكورس ID: $courseIdInt');

      final response = await ApiService.post(
        endpoint: 'enrollment-request/trainee-create/',
        data: {'course': courseIdInt},
        requireAuth: true,
      );

      final success = response['success'] == true;
      print(success ? '✅ [REPO] تم تسجيل الكورس بنجاح' : '❌ [REPO] فشل تسجيل الكورس');
      return success;
    } catch (e) {
      print('❌ [REPO] خطأ في تسجيل الكورس: $e');
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
      print('🗑️ [REPO] إلغاء تسجيل الكورس ID: $courseIdInt');

      final response = await ApiService.delete(
        endpoint: 'enrollment-request/trainee-delete/$courseIdInt/',
        requireAuth: true,
      );

      final success = response['success'] == true;
      print(success ? '✅ [REPO] تم إلغاء التسجيل بنجاح' : '❌ [REPO] فشل إلغاء التسجيل');
      return success;
    } catch (e) {
      print('❌ [REPO] خطأ في إلغاء تسجيل الكورس: $e');
      return false;
    }
  }

  // ============================================================
  // 📚 5. جلب جلسات كورس معين (بدون محتوى)
  // ============================================================
  // تستدعي: GET /api/course-session/trainee-search-by-course-id/{id}/
  Future<List<Session>> getCourseSessions(String courseId) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;
      print('📚 [REPO] جلب الجلسات للكورس ID: $courseIdInt');

      final response = await ApiService.get(
        endpoint: 'course-session/trainee-search-by-course-id/$courseIdInt/',
        requireAuth: true,
      );

      if (response['success']) {
        final rawData = response['data'] ?? response;
        final List<dynamic> data = rawData is List ? rawData : [];
        print('✅ [REPO] تم جلب ${data.length} جلسة');
        return data.map((json) => Session.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [REPO] خطأ في جلب الجلسات: $e');
      return [];
    }
  }

  // ============================================================
  // 📄 6. جلب محتوى كورس معين (جميع الدروس)
  // ============================================================
  // تستدعي: GET /api/course-content/trainee-search-by-course-id/{id}/
  Future<List<CourseContent>> getCourseContent(String courseId) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;
      print('📄 [REPO] جلب المحتوى للكورس ID: $courseIdInt');

      final response = await ApiService.get(
        endpoint: 'course-content/trainee-search-by-course-id/$courseIdInt/',
        requireAuth: true,
      );

      if (response['success']) {
        final rawData = response['data'] ?? response;
        final List<dynamic> data = rawData is List ? rawData : [];
        print('✅ [REPO] تم جلب ${data.length} عنصر محتوى');

        // ✅ طباعة تفاصيل المحتوى للتصحيح
        for (var i = 0; i < data.length; i++) {
          print('   📄 المحتوى ${i+1}: ${data[i]['title']} - session_order: ${data[i]['session_order']}');
        }

        return data.map((json) => CourseContent.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [REPO] خطأ في جلب محتوى الكورس: $e');
      return [];
    }
  }

  // ============================================================
  // ⭐ 7. جلب الجلسات مع المحتوى المرتبط (الدالة الرئيسية)
  // ============================================================
  // هذه الدالة تجلب الجلسات والمحتوى وتربطهما معاً
  Future<List<Session>> getCourseSessionsWithContent(String courseId) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;
      print('═══════════════════════════════════════════════════════');
      print('🔗 [REPO] جلب الجلسات والمحتوى معاً للكورس رقم: $courseIdInt');
      print('═══════════════════════════════════════════════════════');

      // الخطوة 1: جلب الجلسات
      final List<Session> sessions = await getCourseSessions(courseId);
      print('📚 عدد الجلسات المستلمة: ${sessions.length}');

      if (sessions.isEmpty) {
        print('⚠️ [REPO] لا توجد جلسات لهذا الكورس');
        return [];
      }

      // الخطوة 2: جلب المحتوى
      final List<CourseContent> allContents = await getCourseContent(courseId);
      print('📄 عدد عناصر المحتوى المستلمة: ${allContents.length}');

      if (allContents.isEmpty) {
        print('⚠️ [REPO] لا يوجد محتوى لهذا الكورس');
        return sessions;
      }

      // الخطوة 3: إنشاء Map لربط sessionOrder بالجلسة
      // المحتوى يأتي مع session_order يحدد أي جلسة يتبعها
      final Map<int, Session> sessionMap = {};
      for (var session in sessions) {
        if (session.sessionOrder != null) {
          sessionMap[session.sessionOrder!] = session;
          print('   🗂️ جلسة رقم ${session.sessionOrder}: "${session.title}"');
        }
      }

      // الخطوة 4: توزيع المحتوى على الجلسات حسب session_order
      int matchedCount = 0;
      int unmatchedCount = 0;

      for (var content in allContents) {
        final targetSession = sessionMap[content.sessionOrder];
        if (targetSession != null) {
          // ✅ نضيف المحتوى إلى الجلسة المناسبة
          // نستخدم List.from لإنشاء قائمة جديدة قابلة للتعديل
          final updatedContents = List<CourseContent>.from(targetSession.contents);
          updatedContents.add(content);

          // نعيد إنشاء الجلسة مع المحتوى الجديد
          final updatedSession = Session(
            id: targetSession.id,
            course: targetSession.course,
            courseTitle: targetSession.courseTitle,
            title: targetSession.title,
            description: targetSession.description,
            sessionOrder: targetSession.sessionOrder,
            contents: updatedContents,
          );

          // تحديث الجلسة في الـ Map
          sessionMap[content.sessionOrder] = updatedSession;
          matchedCount++;
          print('   ✅ ربط المحتوى "${content.title}" بالجلسة رقم ${content.sessionOrder}');
        } else {
          unmatchedCount++;
          print('   ⚠️ لم نجد جلسة للمحتوى "${content.title}" (session_order=${content.sessionOrder})');
        }
      }

      print('═══════════════════════════════════════════════════════');
      print('📊 [REPO] ملخص الربط:');
      print('   ✅ تم ربط $matchedCount محتوى');
      print('   ⚠️ $unmatchedCount محتوى غير مرتبط');
      print('═══════════════════════════════════════════════════════');

      // الخطوة 5: إعادة بناء قائمة الجلسات مع المحتوى المرتبط
      final List<Session> resultSessions = sessionMap.values.toList();

      // ترتيب الجلسات حسب sessionOrder
      resultSessions.sort((a, b) {
        final orderA = a.sessionOrder ?? 0;
        final orderB = b.sessionOrder ?? 0;
        return orderA.compareTo(orderB);
      });

      // طباعة النتيجة النهائية
      for (var session in resultSessions) {
        print('📚 الجلسة ${session.sessionOrder}: "${session.title}" - ${session.contents.length} دروس');
        for (var content in session.contents) {
          print('      📄 - ${content.title} (${content.contentType})');
        }
      }

      return resultSessions;

    } catch (e) {
      print('❌ [REPO] خطأ في جلب الجلسات مع المحتوى: $e');
      return [];
    }
  }

  // ============================================================
  // 📊 دوال مساعدة (مؤقتة للتوافق)
  // ============================================================

  Future<bool> updateProgress(String userId, String courseId, int progress) async {
    print('📊 [REPO] تحديث التقدم - пользователь: $userId, كورس: $courseId, نسبة: $progress%');
    return true;
  }

  Future<bool> toggleLessonCompletion({
    required String userId,
    required String courseId,
    required String sessionId,
    required String lessonId,
    required bool isCompleted,
  }) async {
    print('📊 [REPO] تبديل حالة إكمال الدرس - الدرس: $lessonId, مكتمل: $isCompleted');
    return true;
  }

  Future<Map<String, dynamic>> calculateOverallProgress(String userId) async {
    print('📊 [REPO] حساب التقدم الإجمالي للمستخدم: $userId');
    return {
      'overallProgress': 0.0,
      'completedLessons': 0,
      'totalLessons': 0
    };
  }

  Future<CourseDetail?> getCourseDetail(String courseId) async {
    try {
      final courseIdInt = int.tryParse(courseId) ?? 0;
      print('📋 [REPO] جلب تفاصيل الكورس ID: $courseIdInt');

      final sessions = await getCourseSessionsWithContent(courseId);
      if (sessions.isEmpty) return null;

      // نحتاج إلى عنوان الكورس من أول جلسة
      final firstSession = sessions.first;

      return CourseDetail(
        id: courseIdInt,
        title: firstSession.courseTitle,
        description: '',
        sessions: sessions,
      );
    } catch (e) {
      print('❌ [REPO] خطأ في جلب تفاصيل الكورس: $e');
      return null;
    }
  }
}

// ============================================================
// 📦 نموذج تفاصيل الكورس (إذا لم يكن موجوداً)
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