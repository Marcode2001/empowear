// 📄 lib/repositories/job_repository.dart
// ============================================================
// 💼 Repository إدارة الوظائف والتقديمات
// ============================================================

import '../models/job_models.dart';
import '../services/api_service.dart';

class JobRepository {

  // ============================================================
  // 📥 1. جلب جميع الوظائف
  // ============================================================

  Future<List<JobModel>> fetchJobs({
    String? category,
  }) async {

    try {

      // ✅ بارامترات اختيارية للفلترة
      final Map<String, String> queryParams = {};

      if (category != null && category != 'all') {

        queryParams['category'] = category;
      }

      // ✅ إرسال الطلب للباك
      final response = await ApiService.get(

        endpoint: 'jobs',

        queryParams: queryParams,

        requireAuth: true,
      );

      print("📦 Jobs API Response:");
      print(response);

      // ✅ التحقق من نجاح الطلب
      if (response['success'] == true) {

        final dynamic rawData = response['data'];

        // ✅ التأكد أن البيانات List
        if (rawData is List) {

          // ✅ تحويل JSON إلى JobModel
          return rawData
              .map((json) => JobModel.fromJson(json))
              .toList();
        }
      }

      return [];

    } catch (e) {

      print('❌ fetchJobs Error: $e');

      return [];
    }
  }

  // ============================================================
  // 📥 2. جلب تفاصيل وظيفة معينة
  // ============================================================

  Future<JobModel> fetchJobDetail(
      String jobId,
      ) async {

    try {

      final response = await ApiService.get(

        endpoint: 'jobs/$jobId',

        requireAuth: true,
      );

      print('📦 Job Detail Response:');
      print(response);

      if (response['success'] == true) {

        return JobModel.fromJson(
          response['data'],
        );
      }

      throw Exception(
        'Failed to load job details',
      );

    } catch (e) {

      print('❌ fetchJobDetail Error: $e');

      rethrow;
    }
  }

  // ============================================================
  // 📤 3. التقديم على وظيفة
  // ============================================================

  Future<bool> applyForJob({

    required String jobId,

    required String userId,

    required String userName,

    required String userEmail,

    String? coverLetter,

    String? resumeUrl,

  }) async {

    try {

      // ✅ إرسال طلب التقديم
      final response = await ApiService.post(

        endpoint: 'application/apply/',

        data: {

          // ✅ الباك يتطلب ID الوظيفة
          'job_opportunity': int.parse(jobId),
        },

        requireAuth: true,
      );

      print('📦 Apply Response:');
      print(response);

      // ✅ نجاح العملية
      return response['success'] == true;

    } catch (e) {

      print('❌ applyForJob Error: $e');

      return false;
    }
  }

  // ============================================================
  // ❌ 4. سحب التقديم على وظيفة
  // ============================================================

  

  // ============================================================
  // 📥 5. جلب طلبات التقديم الخاصة بالمستخدم
  // ============================================================

  Future<List<JobApplication>>
  fetchUserApplications(

      String userId,

      ) async {

    try {

      // ✅ جلب كل الطلبات الخاصة بالمستخدم الحالي
      final response = await ApiService.get(

        endpoint: 'application/',

        requireAuth: true,
      );

      print('📦 APPLICATIONS RESPONSE');
      print(response);

      // ✅ إذا فشل الطلب
      if (response['success'] != true) {

        return [];
      }

      // ✅ البيانات القادمة من السيرفر
      final List<dynamic> data =
      response['data'];

      // ✅ تحويل كل عنصر إلى JobApplication
      return data.map((json) {

        return JobApplication(

          // ✅ ID التقديم نفسه
          id: json['id'].toString(),

          // ✅ ID الوظيفة
          jobId:
          json['job_opportunity']
              .toString(),

          // ✅ اسم الوظيفة
          jobTitle:
          json['job_title']
              ?? 'Unknown Job',

          // ✅ اسم الشركة المؤقت
          company: 'Empower',

          // ✅ لوجو مؤقت
          companyLogo: '🏢',

          // ✅ الموقع
          location:
          json['location'] ?? '',

          // ✅ الراتب
          salary: 'Not specified',

          // ✅ تاريخ التقديم
          appliedDate:

          DateTime.tryParse(

            json['applied_at'] ?? '',

          ) ?? DateTime.now(),

          // ✅ حالة الطلب
          status:
          ApplicationStatusExtension
              .fromString(

            json['application_status']
                ?? 'pending',
          ),
        );

      }).toList();

    } catch (e) {

      print(
        '❌ fetchUserApplications Error: $e',
      );

      return [];
    }
  }

  // ============================================================
  // 📊 6. تحديث حالة التقديم
  // ============================================================

  Future<bool> updateApplicationStatus({

    required String applicationId,

    required String newStatus,

    String? feedback,

  }) async {

    try {

      String endpoint = '';

      // ✅ قبول الطلب
      if (newStatus == 'approved') {

        endpoint =
        'application/$applicationId/accept/';

      }

      // ✅ رفض الطلب
      else {

        endpoint =
        'application/$applicationId/reject/';
      }

      final response = await ApiService.put(

        endpoint: endpoint,

        data: {},

        requireAuth: true,
      );

      print('📦 Update Status Response:');
      print(response);

      return response['success'] == true;

    } catch (e) {

      print(
        '❌ updateApplicationStatus Error: $e',
      );

      return false;
    }
  }

  // ============================================================
  // 🔄 7. تحديث الطلبات
  // ============================================================

  Future<List<JobApplication>>
  refreshUserApplications(

      String userId,

      ) async {

    // ✅ إعادة تحميل الطلبات من السيرفر
    return await fetchUserApplications(
      userId,
    );
  }
}