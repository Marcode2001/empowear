// lib/repositories/project_repository.dart
// ✅ ربط مع Design Submission في Django
import '../models/project_models.dart';
import '../services/api_service.dart';

class ProjectRepository {

  // 📥 تحميل المشاريع المميزة (غير موجود في الـ API)
  Future<List<FeaturedProject>> loadFeaturedProjects() async {
    // نرجع بيانات وهمية مؤقتاً
    return [];
  }

  // 📥 تحميل المشاريع المطلوبة (للكورس) = الـ Sessions
  Future<List<RequiredProject>> loadRequiredProjects(String courseId) async {
    final response = await ApiService.get(
      endpoint: 'course-content/trainee-search-by-course-id/$courseId/',
      requireAuth: true,
    );

    if (response['success']) {
      final data = response['data'];
      final List<dynamic> sessions = data['sessions'] ?? [];
      return sessions.map((json) => RequiredProject.fromJson(json)).toList();
    }
    return [];
  }

  // 📥 تحميل مشاريع الطالب الخاصة به = الـ Submissions
  Future<List<StudentProject>> loadMyProjects(String studentId) async {
    final response = await ApiService.get(
      endpoint: 'design-submission/trainee-my-submissions/',
      requireAuth: true,
    );

    if (response['success']) {
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => StudentProject.fromJson(json)).toList();
    }
    return [];
  }

  // 📥 تحميل تسليمات الطلاب (للمدرب)
  Future<List<ProjectSubmission>> loadStudentSubmissions(String projectId) async {
    final response = await ApiService.get(
      endpoint: 'design-submission/trainer-all-submissions/',
      requireAuth: true,
    );

    if (response['success']) {
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ProjectSubmission.fromJson(json)).toList();
    }
    return [];
  }

  // 📤 رفع مشروع جديد = Submit Design
  Future<bool> submitProject({
    required String projectId,
    required String studentId,
    required String projectUrl,
    String? description,
    String? imageUrl,
  }) async {
    final response = await ApiService.postMultipart(
      endpoint: 'design-submission/trainee-create/',
      fields: {
        'course': projectId,  // projectId هنا هو courseId
        'course_session': '',
        'session_order': '',
        'title': description ?? 'مشروع جديد',
      },
      filePath: imageUrl,
      fileFieldName: 'image',
    );
    return response['success'];
  }

  // 📝 تصحيح مشروع (للمدرب) = Create Evaluation
  Future<bool> gradeSubmission({
    required String submissionId,
    required double grade,
    required String feedback,
  }) async {
    // تحويل الـ grade إلى حرف (A+, A, B+, etc.)
    String gradeLetter = _gradeToLetter(grade);

    final response = await ApiService.post(
      endpoint: 'design-evaluation/trainer-create/',
      data: {
        'design_submission': int.parse(submissionId),
        'grade_letter': gradeLetter,
      },
      requireAuth: true,
    );
    return response['success'];
  }

  String _gradeToLetter(double grade) {
    if (grade >= 90) return 'A+';
    if (grade >= 85) return 'A';
    if (grade >= 80) return 'B+';
    if (grade >= 75) return 'B';
    if (grade >= 70) return 'C+';
    if (grade >= 65) return 'C';
    return 'D';
  }
}