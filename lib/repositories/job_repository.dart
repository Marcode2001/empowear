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

    print("📦 Jobs API Response:");
    print(response);

    /// ✅ هون الحل الحقيقي
    /// الـ API عم يرجع List مباشرة
    if (response['success'] == true) {

      final dynamic rawData = response['data'];

      if (rawData is List) {

        return rawData
            .map((json) => JobModel.fromJson(json))
            .toList();
      }
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
      endpoint: 'application/apply/',
      data: {
        'job_opportunity': int.parse(jobId),
      },
      requireAuth: true,
    );

    print(response);

    return response['success'] == true;
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
  // 📥 5. جلب طلبات التقديم الخاصة بالمستخدم
  Future<List<JobApplication>> fetchUserApplications(
      String userId,
      ) async {

    try {

      final response = await ApiService.get(
        endpoint: 'application/',
        requireAuth: true,
      );

      print('📦 APPLICATIONS RESPONSE');
      print(response);

      if (response['success'] != true) {
        return [];
      }

      final List<dynamic> data = response['data'];

      return data.map((json) {

        return JobApplication(
          id: json['id'].toString(),

          jobId: json['job_opportunity'].toString(),

          jobTitle: json['job_title'] ?? 'Unknown Job',

          company: 'Empower',

          companyLogo: '🏢',

          location: json['location'] ?? '',

          salary: 'Not specified',

          appliedDate: DateTime.tryParse(
            json['applied_at'] ?? '',
          ) ?? DateTime.now(),

          status: ApplicationStatusExtension.fromString(
            json['application_status'] ?? 'pending',
          ),
        );

      }).toList();

    } catch (e) {

      print('❌ fetchUserApplications Error: $e');

      return [];
    }
  }

  // 📊 6. تحديث حالة التقديم (للمدرب/الأدمن)
  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String newStatus,
    String? feedback,
  }) async {

    String endpoint = '';

    if (newStatus == 'approved') {
      endpoint = 'application/$applicationId/accept/';
    } else {
      endpoint = 'application/$applicationId/reject/';
    }

    final response = await ApiService.put(
      endpoint: endpoint,
      data: {},
      requireAuth: true,
    );

    print(response);

    return response['success'] == true;
  }

  // 🔄 7. تحديث قائمة طلبات التقديم
  Future<List<JobApplication>> refreshUserApplications(String userId) async {
    return await fetchUserApplications(userId);
  }
}
//___________________________________________________________________________