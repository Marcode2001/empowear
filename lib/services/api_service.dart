// 📄 lib/services/api_service.dart
// ============================================================
// 🌐 الـ API Service الأساسي للتواصل مع الباك اند
// ============================================================
// الوظيفة: إدارة جميع طلبات API
// - إعداد headers (Authorization, Content-Type)
// - معالجة الأخطاء
// - تنفيذ طلبات GET, POST, PUT, DELETE

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 🌐 رابط الـ API الأساسي (يتم تغييره حسب البيئة)
  static const String baseUrl = 'http://192.168.1.22:8000/api';

  // ⏱️ مهلة الاتصال (بالثواني)
  static const int timeoutSeconds = 30;

  // 🔑 الحصول على التوكن من التخزين المحلي
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // 📝 إعداد headers للطلبات
  static Future<Map<String, String>> getHeaders({bool requireAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // 📤 طلب GET
  static Future<Map<String, dynamic>> get({
    required String endpoint,
    bool requireAuth = true,
    Map<String, String>? queryParams,
  }) async {
    try {
      // بناء الـ URL مع query parameters
      var uri = Uri.parse('$baseUrl/$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await getHeaders(requireAuth: requireAuth);
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: timeoutSeconds),
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 📤 طلب POST
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> data,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final headers = await getHeaders(requireAuth: requireAuth);
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: timeoutSeconds));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 📤 طلب PUT
  static Future<Map<String, dynamic>> put({
    required String endpoint,
    required Map<String, dynamic> data,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final headers = await getHeaders(requireAuth: requireAuth);
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: timeoutSeconds));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 📤 طلب PATCH
  static Future<Map<String, dynamic>> patch({
    required String endpoint,
    required Map<String, dynamic> data,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final headers = await getHeaders(requireAuth: requireAuth);
      final response = await http.patch(
        uri,
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: timeoutSeconds));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 📤 طلب DELETE
  static Future<Map<String, dynamic>> delete({
    required String endpoint,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final headers = await getHeaders(requireAuth: requireAuth);
      final response = await http.delete(uri, headers: headers).timeout(
        const Duration(seconds: timeoutSeconds),
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 🔄 معالجة الرد من الخادم
  // 📄 lib/services/api_service.dart
// استبدلي دالة _handleResponse بهذه النسخة المعدّلة:

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> result = {
      'success': false,
      'statusCode': response.statusCode,
      'data': null,
      'message': '',
    };

    try {
      // ✅ نستخدم dynamic بدل Map عشان نقبل ردود JSON من نوع List أو Object
      final dynamic decoded = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        result['success'] = true;
        result['data'] = decoded; // رح تكون List في حالتنا الحالية

        // استخراج الرسالة إن وجدت (بس لو الرد كائن مو قائمة)
        if (decoded is Map<String, dynamic>) {
          result['message'] = decoded['message'] ?? 'Success';
        } else {
          result['message'] = 'Success';
        }
      } else {
        if (decoded is Map<String, dynamic>) {
          result['message'] = decoded['message'] ?? 'Something went wrong';
        } else {
          result['message'] = 'Server Error (${response.statusCode})';
        }
      }
    } catch (e) {
      // 🛑 لو فشل التحليل (نص فاضي أو رد غير JSON)
      print('⚠️ JSON Parse Error: $e');
      result['message'] = 'Failed to parse response';
    }

    return result;
  }

  // ❌ معالجة الأخطاء
  static Map<String, dynamic> _handleError(dynamic error) {
    print('🔴 API Error: $error');
    return {
      'success': false,
      'statusCode': 0,
      'data': null,
      'message': 'Network error: ${error.toString()}',
    };
  }

  // lib/services/api_service.dart
// أضيفي هذه الدالة داخل class ApiService

  // 🖼️ POST مع ملف (Multipart) - لرفع الصور والملفات
  static Future<Map<String, dynamic>> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    String? filePath,
    String fileFieldName = 'file',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // إضافة التوكن للهيدر
      final token = await getToken();
      request.headers['Accept'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // إضافة الحقول النصية
      request.fields.addAll(fields);

      // إضافة الملف إذا وجد
      if (filePath != null && filePath.isNotEmpty) {
        final file = await http.MultipartFile.fromPath(fileFieldName, filePath);
        request.files.add(file);
      }

      // إرسال الطلب
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final decoded = json.decode(responseBody);

      return {
        'success': streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300,
        'data': decoded,
        'statusCode': streamedResponse.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'فشل رفع الملف: $e',
      };
    }
  }
}