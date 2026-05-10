// 📄 lib/models/course_models.dart
// ============================================================
// 📦 نماذج بيانات الكورسات - الإصدار النهائي
// ============================================================

import 'package:flutter/material.dart';

// ============================================================
// 📚 نموذج محتوى الكورس (CourseContent)
// ============================================================
// هذا النموذج يمثل ملفاً واحداً (PDF، فيديو، صورة) داخل الجلسة

class CourseContent {
  final int id;                    // المعرف الفريد للمحتوى (رقم من قاعدة البيانات)
  final int course;                // معرف الكورس التابع له
  final int courseSession;         // معرف الجلسة التابعة لها
  final int sessionOrder;          // ترتيب الجلسة (1,2,3...)
  final String title;              // عنوان المحتوى (مثل "الدرس 1")
  final String contentType;        // نوع الملف: 'PDF', 'VIDEO', 'IMAGE'
  final int contentOrder;          // ترتيب المحتوى داخل الجلسة
  final String? fileUrl;           // رابط الملف (مثل /media/files/lesson1.pdf)

  // 🏗️ الكونستركتور - ينشئ كائن CourseContent
  CourseContent({
    required this.id,
    required this.course,
    required this.courseSession,
    required this.sessionOrder,
    required this.title,
    required this.contentType,
    required this.contentOrder,
    this.fileUrl,
  });

  // ✅ تحويل JSON (من الخادم) إلى كائن CourseContent
  factory CourseContent.fromJson(Map<String, dynamic> json) {
    // 🔍 نطبع في الكونسول لنرى الرابط القادم من الخادم
    print('📄 [CourseContent] تحويل: ${json['title']}');
    print('   📁 الرابط الخام: ${json['file'] ?? json['file_url']}');

    // نحاول قراءة الرابط من عدة حقول محتملة
    String? fileUrlValue;
    if (json['file'] != null && json['file'].toString().isNotEmpty) {
      fileUrlValue = json['file'].toString();
    } else if (json['file_url'] != null && json['file_url'].toString().isNotEmpty) {
      fileUrlValue = json['file_url'].toString();
    }

    return CourseContent(
      id: json['id'] ?? 0,
      course: json['course'] ?? 0,
      courseSession: json['course_session'] ?? 0,
      sessionOrder: json['session_order'] ?? 0,
      title: json['title'] ?? 'بدون عنوان',
      contentType: json['content_type'] ?? 'FILE',
      contentOrder: json['content_order'] ?? 0,
      fileUrl: fileUrlValue,  // ✅ الرابط كما هو من الخادم
    );
  }

  // ✅ دوال مساعدة للواجهة (لتسهيل العرض)

  // نوع المحتوى بأحرف صغيرة (مثلاً 'pdf' بدلاً من 'PDF')
  String get type => contentType.toLowerCase();

  // هل يوجد ملف حقيقي (الرابط ليس فارغاً)
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;

  // مدة وهمية للعرض (حسب ترتيب المحتوى)
  String get duration => '${(contentOrder * 5).clamp(5, 60)} min';

  // ✅ أيقونة مناسبة حسب نوع المحتوى
  IconData get icon {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'video': return Icons.video_library;
      case 'image': return Icons.image;
      default: return Icons.insert_drive_file;
    }
  }

  // ✅ لون مناسب حسب نوع المحتوى
  Color get color {
    switch (type) {
      case 'pdf': return Colors.red;
      case 'video': return Colors.blue;
      case 'image': return Colors.green;
      default: return Colors.grey;
    }
  }

  // ✅ بناء الرابط الكامل (مع إضافة base URL إذا لزم الأمر)
  String get fullUrl {
    if (!hasFile) return '';
    // إذا كان الرابط يبدأ بـ http أو https، نستخدمه كما هو
    if (fileUrl!.startsWith('http')) return fileUrl!;
    // وإلا نضيف الرابط الأساسي للخادم
    return 'http://192.168.1.22:8000$fileUrl!';
  }
}

// ============================================================
// 📋 نموذج الدرس (Lesson) - للواجهة فقط
// ============================================================
// هذا نموذج مبسط للعرض في الواجهة

class Lesson {
  final String id;           // معرف الدرس (نص)
  final String title;        // عنوان الدرس
  final String duration;     // المدة (مثل "10 min")
  final String type;         // النوع: 'video', 'pdf', 'image'
  final String url;          // رابط الملف الكامل
  final bool isCompleted;    // هل تم إكمال الدرس؟

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.type,
    required this.url,
    this.isCompleted = false,
  });

  // ✅ تحويل من CourseContent إلى Lesson
  factory Lesson.fromCourseContent(CourseContent content) {
    return Lesson(
      id: content.id.toString(),
      title: content.title,
      duration: content.duration,
      type: content.type,
      url: content.fullUrl,  // ✅ نستخدم الرابط الكامل هنا
      isCompleted: false,
    );
  }
}

// ============================================================
// 📋 نموذج الجلسة (Session)
// ============================================================
// يمثل جلسة واحدة داخل كورس (مثل "الأسبوع الأول")

class Session {
  final int id;                    // معرف الجلسة
  final int course;                // معرف الكورس
  final String courseTitle;        // عنوان الكورس
  final String title;              // عنوان الجلسة
  final String description;        // وصف الجلسة
  final int? sessionOrder;         // ترتيب الجلسة (1,2,3...)
  final List<CourseContent> contents;  // محتويات الجلسة (الدروس)

  // 🏗️ الكونستركتور
  Session({
    required this.id,
    required this.course,
    required this.courseTitle,
    required this.title,
    required this.description,
    this.sessionOrder,
    this.contents = const [],
  });

  // ✅ تحويل JSON إلى كائن Session
  factory Session.fromJson(Map<String, dynamic> json) {
    // نقرأ المحتويات إذا كانت موجودة في JSON
    final List<dynamic> contentsData = json['contents'] ?? json['course_content'] ?? [];

    return Session(
      id: json['id'] ?? 0,
      course: json['course'] ?? 0,
      courseTitle: json['course_title'] ?? 'كورس غير معروف',
      title: json['session_title'] ?? json['title'] ?? 'جلسة بدون عنوان',
      description: json['description'] ?? '',
      sessionOrder: json['session_order'],
      contents: contentsData.map((c) => CourseContent.fromJson(c)).toList(),
    );
  }

  // ✅ عدد المحتويات في الجلسة
  int get lessonsCount => contents.length;

  // ✅ تحويل قائمة CourseContent إلى قائمة Lesson للواجهة
  List<Lesson> get curriculum {
    return contents.map((content) => Lesson.fromCourseContent(content)).toList();
  }
}

// ============================================================
// 🎓 نموذج الكورس (CourseItem)
// ============================================================
// يمثل كورس كامل مع جميع بياناته

class CourseItem {
  final String id;                 // معرف الكورس (نص)
  final String title;              // عنوان الكورس
  final String description;        // وصف الكورس
  final int levelNumber;           // رقم المستوى
  final String courseType;         // نوع الكورس
  final String price;              // السعر
  final String toolsRequired;      // الأدوات المطلوبة
  final int trainerProfile;        // معرف المدرب
  final String trainerName;        // اسم المدرب
  final int studentsCount;         // عدد الطلاب
  final String totalHours;         // المدة الكلية
  final List<Session> sessions;    // قائمة الجلسات
  final bool isRegistered;         // هل الطالب مسجل؟
  final int progress;              // نسبة التقدم

  // 🏗️ الكونستركتور
  CourseItem({
    required this.id,
    required this.title,
    required this.description,
    required this.levelNumber,
    required this.courseType,
    required this.price,
    required this.toolsRequired,
    required this.trainerProfile,
    required this.trainerName,
    this.studentsCount = 0,
    this.totalHours = '0h',
    this.sessions = const [],
    this.isRegistered = false,
    this.progress = 0,
  });

  // ✅ تحويل JSON إلى كائن CourseItem
  factory CourseItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> sessionsData = json['sessions'] ?? [];

    // معالجة السعر (قد يكون رقماً أو نصاً)
    final priceValue = json['price'];
    final priceString = priceValue is num
        ? priceValue.toStringAsFixed(2)
        : (priceValue?.toString() ?? '0');

    // معالجة اسم المدرب (قد يكون في أماكن مختلفة)
    String trainerName = '';
    if (json['trainer_full_name'] != null) {
      trainerName = json['trainer_full_name'];
    } else if (json['trainerName'] != null) {
      trainerName = json['trainerName'];
    } else if (json['trainer_profile'] is Map) {
      trainerName = json['trainer_profile']['full_name'] ?? 'مدرب غير معروف';
    } else if (json['trainer_profile'] is int) {
      trainerName = 'مدرب رقم ${json['trainer_profile']}';
    } else {
      trainerName = 'مدرب غير معروف';
    }

    return CourseItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'كورس بدون عنوان',
      description: json['description'] ?? '',
      levelNumber: json['level_number'] ?? json['levelNumber'] ?? 1,
      courseType: json['course_type'] ?? json['courseType'] ?? 'عام',
      price: priceString,
      toolsRequired: json['tools_required'] ?? json['toolsRequired'] ?? '',
      trainerProfile: json['trainer_profile'] is Map
          ? (json['trainer_profile']['id'] ?? 0)
          : (json['trainer_profile'] ?? 0),
      trainerName: trainerName,
      studentsCount: json['studentsCount'] ?? json['students_count'] ?? 0,
      totalHours: json['totalHours'] ?? json['total_hours'] ?? '0h',
      sessions: sessionsData.map((s) => Session.fromJson(s)).toList(),
      isRegistered: json['is_registered'] ?? false,
      progress: json['progress'] ?? 0,
    );
  }

  // ✅ عدد الجلسات في الكورس
  int get sessionsCount => sessions.length;

  // ✅ إجمالي عدد الدروس في كل الجلسات
  int get totalLessons => sessions.fold(0, (sum, s) => sum + s.lessonsCount);

  // ✅ ✅ ✅ دالة copyWith - لإنشاء نسخة جديدة من الكورس مع تعديل بعض الحقول
  // هذه الدالة مهمة جداً لتحديث حالة التسجيل بدون تغيير باقي البيانات
  CourseItem copyWith({
    String? id,                   // معرف الكورس
    String? title,                // عنوان الكورس
    String? description,          // وصف الكورس
    int? levelNumber,             // رقم المستوى
    String? courseType,           // نوع الكورس
    String? price,                // السعر
    String? toolsRequired,        // الأدوات المطلوبة
    int? trainerProfile,          // معرف المدرب
    String? trainerName,          // اسم المدرب
    int? studentsCount,           // عدد الطلاب
    String? totalHours,           // المدة الكلية
    List<Session>? sessions,      // قائمة الجلسات
    bool? isRegistered,           // حالة التسجيل (الأهم)
    int? progress,                // نسبة التقدم
  }) {
    return CourseItem(
      id: id ?? this.id,                    // إذا لم يتم تمرير قيمة جديدة، استخدم القديمة
      title: title ?? this.title,
      description: description ?? this.description,
      levelNumber: levelNumber ?? this.levelNumber,
      courseType: courseType ?? this.courseType,
      price: price ?? this.price,
      toolsRequired: toolsRequired ?? this.toolsRequired,
      trainerProfile: trainerProfile ?? this.trainerProfile,
      trainerName: trainerName ?? this.trainerName,
      studentsCount: studentsCount ?? this.studentsCount,
      totalHours: totalHours ?? this.totalHours,
      sessions: sessions ?? this.sessions,
      isRegistered: isRegistered ?? this.isRegistered,  // ✅ نعدل حالة التسجيل فقط
      progress: progress ?? this.progress,
    );
  }
}