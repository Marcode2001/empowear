import '../models/certificate_model.dart';
import '../services/api_service.dart';

class CertificateRepository {

  Future<List<CertificateModel>> getMyCertificates() async {
    final response = await ApiService.get(
      endpoint: 'certificate/trainee-my-certificates/',
      requireAuth: true,
    );

    if (response['success'] == true || response['statusCode'] == 200) {
      final List data = response['data'];
      return data.map((e) => CertificateModel.fromJson(e)).toList();
    }

    return [];
  }


  // =========================================================
  // 👨‍💼 Admin Get All
  // =========================================================
  Future<List<CertificateModel>> getAllCertificates() async {

    final response = await ApiService.get(
      endpoint: 'certificate/admin-all-certificates/',
      requireAuth: true,
    );

    if (response['success']) {

      final List data = response['data'];

      return data
          .map((e) => CertificateModel.fromJson(e))
          .toList();
    }

    return [];
  }


  Future<Map<String, dynamic>> getCertificateByLevel(int level) async {
    final response = await ApiService.post(
      endpoint: 'certificate/trainee-get-or-generate-by-course-level/$level/',
      data: {},
      requireAuth: true,
    );

    return {
      'success': response['success'],
      'data': response['data'] ?? response['certificate'],
      'message': response['message'],
    };
  }

  // =========================================================
  // 🔎 Admin Search
  // =========================================================
  Future<List<CertificateModel>> searchCertificates(
      String fullName,
      ) async {

    final response = await ApiService.get(
      endpoint:
      'certificate/admin-search-by-trainee-full-name/',
      queryParams: {
        'full_name': fullName,
      },
      requireAuth: true,
    );

    if (response['success']) {

      final List data = response['data'];

      return data
          .map((e) => CertificateModel.fromJson(e))
          .toList();
    }

    return [];
  }
}