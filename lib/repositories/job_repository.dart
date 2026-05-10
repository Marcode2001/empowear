// 📄 lib/repositories/job_repository.dart
// ============================================================
// 💼 الـ Repository لفرص العمل (Jobs)
// ============================================================

import '../models/job_models.dart';
import '../services/api_service.dart';

class JobRepository {

  // 📥 1. جلب جميع الوظائف
  Future<List<JobModel>> fetchJobs({String? category}) async {
    final Map<String, String> queryParams = {};
    if (category != null && category != 'all') {
      queryParams['category'] = category;
    }

    final response = await ApiService.get(
      endpoint: 'jobs',
      queryParams: queryParams,
      requireAuth: true,
    );

    if (response['success']) {
      final List<dynamic> data = response['data']['jobs'] ?? [];
      return data.map((json) => JobModel.fromJson(json)).toList();
    }

    return [];
  }

  // 📥 2. جلب تفاصيل وظيفة معينة
  Future<JobModel> fetchJobDetail(String jobId) async {
    final response = await ApiService.get(
      endpoint: 'jobs/$jobId',
      requireAuth: true,
    );

    if (response['success']) {
      return JobModel.fromJson(response['data']);
    }

    throw Exception('Failed to load job details');
  }

  // 📤 3. التقديم على وظيفة
  Future<bool> applyForJob({
    required String jobId,
    required String userId,
    required String userName,
    required String userEmail,
    String? coverLetter,
    String? resumeUrl,
  }) async {
    final response = await ApiService.post(
      endpoint: 'jobs/$jobId/apply',
      data: {
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'coverLetter': coverLetter,
        'resumeUrl': resumeUrl,
        'status': 'pending',
      },
      requireAuth: true,
    );

    return response['success'];
  }

  // 🗑️ 4. سحب التقديم على وظيفة
  Future<bool> withdrawApplication(String jobId, String userId) async {
    final response = await ApiService.delete(
      endpoint: 'jobs/$jobId/applications/$userId',
      requireAuth: true,
    );

    return response['success'];
  }

  // 📥 5. جلب طلبات التقديم الخاصة بالمستخدم
  Future<List<JobApplication>> fetchUserApplications(String userId) async {
    final response = await ApiService.get(
      endpoint: 'users/$userId/job-applications',
      requireAuth: true,
    );

    if (response['success']) {
      final List<dynamic> data = response['data']['applications'] ?? [];
      return data.map((json) => JobApplication.fromJson(json)).toList();
    }

    return [];
  }

  // 📊 6. تحديث حالة التقديم (للمدرب/الأدمن)
  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String newStatus,
    String? feedback,
  }) async {
    final response = await ApiService.patch(
      endpoint: 'applications/$applicationId/status',
      data: {
        'status': newStatus,
        'feedback': feedback,
      },
      requireAuth: true,
    );

    return response['success'];
  }

  // 🔄 7. تحديث قائمة طلبات التقديم
  Future<List<JobApplication>> refreshUserApplications(String userId) async {
    return await fetchUserApplications(userId);
  }
}
//___________________________________________________________________________