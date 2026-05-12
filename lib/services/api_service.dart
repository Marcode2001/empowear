// 📄 lib/services/api_service.dart
// ============================================================
// 🌐 الـ API Service الأساسي للتواصل مع الباك اند
// ============================================================
// الوظيفة: إدارة جميع طلبات API
// - إعداد headers (Authorization, Content-Type)
// - معالجة الأخطاء
// - تنفيذ طلبات GET, POST, PUT, DELETE
// ✅ مع إضافة أكواد التصحيح (Debug Logs)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 🌐 رابط الـ API الأساسي (يتم تغييره حسب البيئة)
  // ⚠️ IMPORTANT: غير هذا الرابط حسب عنوان جهازك
  static const String baseUrl = 'http://192.168.1.22:8000/api';

  // ⏱️ مهلة الاتصال (بالثواني)
  static const int timeoutSeconds = 30;

  // 🔑 الحصول على التوكن من التخزين المحلي
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('🔑 [API] Token موجود: ${token != null ? "نعم (${token.substring(0, min(20, token.length))}...)" : "لا"}');
    return token;
  }

  // دالة مساعدة لطباعة جزء من النص
  static int min(int a, int b) => a < b ? a : b;

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
        print('🔑 [API] تم إضافة التوكن إلى الـ Headers');
      } else {
        print('⚠️ [API] لا يوجد توكن - الطلب قد يفشل');
      }
    }

    return headers;
  }

  // 📤 طلب GET (مع تصحيح مفصل)
  static Future<Map<String, dynamic>> get({
    required String endpoint,
    bool requireAuth = true,
    Map<String, String>? queryParams,
    int retryCount = 0,  // ✅ أضف هذا parameter
  }) async {
    try {
      // بناء الـ URL مع query parameters
      var uri = Uri.parse('$baseUrl/$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      // ✅ طباعة تفاصيل الطلب للتصحيح
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🌐 [API] 🌐 GET REQUEST 🌐');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $uri');
      print('🔐 Requires Auth: $requireAuth');

      final headers = await getHeaders(requireAuth: requireAuth);
      print('📋 Headers: $headers');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final stopwatch = Stopwatch()..start();
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: timeoutSeconds),
      );
      stopwatch.stop();

      // ✅ طباعة تفاصيل الاستجابة
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📥 [API] 📥 GET RESPONSE 📥');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('⏱️  الوقت المستغرق: ${stopwatch.elapsedMilliseconds}ms');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Body: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // ✅ إذا كان التوكن منتهياً (401) ولم نعد المحاولة أكثر من مرة
      if (response.statusCode == 401 && retryCount == 0 && requireAuth) {
        print('⚠️ [API] التوكن منتهي - محاولة التجديد...');

        final refreshed = await refreshToken();
        if (refreshed) {
          print('✅ [API] تم تجديد التوكن - إعادة المحاولة...');
          // إعادة المحاولة مع التوكن الجديد
          return await get(
            endpoint: endpoint,
            requireAuth: requireAuth,
            queryParams: queryParams,
            retryCount: retryCount + 1,
          );
        } else {
          print('❌ [API] فشل تجديد التوكن - يجب تسجيل الدخول مرة أخرى');
          // يمكن إضافة حدث لتسجيل الخروج هنا
        }
      }

      return _handleResponse(response);
    } catch (e) {
      print('❌ [API] خطأ في طلب GET: $e');
      return _handleError(e);
    }
  }

  // 📤 طلب POST
  // 📤 طلب POST (مع إعادة محاولة)
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> data,
    bool requireAuth = true,
    int retryCount = 0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🌐 [API] 🌐 POST REQUEST 🌐');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 URL: $uri');
      print('📦 Data: $data');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final headers = await getHeaders(requireAuth: requireAuth);
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: timeoutSeconds));

      print('📊 [API] POST Response Status: ${response.statusCode}');
      print('📝 [API] POST Response Body: ${response.body}');

      // ✅ إذا كان التوكن منتهياً
      if (response.statusCode == 401 && retryCount == 0 && requireAuth) {
        print('⚠️ [API] التوكن منتهي في POST - محاولة التجديد...');
        final refreshed = await refreshToken();
        if (refreshed) {
          return await post(
            endpoint: endpoint,
            data: data,
            requireAuth: requireAuth,
            retryCount: retryCount + 1,
          );
        }
      }

      return _handleResponse(response);
    } catch (e) {
      print('❌ [API] خطأ في طلب POST: $e');
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

      print('📊 [API] PUT Response Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ [API] خطأ في طلب PUT: $e');
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

      print('📊 [API] PATCH Response Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ [API] خطأ في طلب PATCH: $e');
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

      print('📊 [API] DELETE Response Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ [API] خطأ في طلب DELETE: $e');
      return _handleError(e);
    }
  }

  // 📄 lib/services/api_service.dart
// أضف هذه الدالة داخل class ApiService

  static Future<void> handleTokenExpired() async {
    print('🚪 [API] Token expired - logging out...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    // يمكنك إضافة حدث لتوجيه المستخدم لشاشة تسجيل الدخول
  }

  // ============================================================
  // 🔄 معالجة الرد من الخادم (نسخة معدلة مع تصحيح)
  // ============================================================
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> result = {
      'success': false,
      'statusCode': response.statusCode,
      'data': null,
      'message': '',
    };

    // ✅ إذا كان الرد فارغاً
    if (response.body.isEmpty) {
      print('⚠️ [API] Response body is empty');
      result['message'] = 'Empty response from server';
      return result;
    }

    try {
      // ✅ تحليل JSON
      final dynamic decoded = json.decode(response.body);

      print('🔍 [API] Decoded response type: ${decoded.runtimeType}');

      // ✅ إذا كان الطلب ناجحاً (2xx)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        result['success'] = true;
        result['data'] = decoded;

        // استخراج الرسالة إن وجدت
        if (decoded is Map<String, dynamic>) {
          result['message'] = decoded['message'] ?? 'Success';
          print('✅ [API] Success - Message: ${result['message']}');
        } else if (decoded is List) {
          result['message'] = 'Success - ${decoded.length} items received';
          print('✅ [API] Success - Received ${decoded.length} items (List)');
        } else {
          result['message'] = 'Success';
          print('✅ [API] Success - Data type: ${decoded.runtimeType}');
        }
      }
      // ✅ إذا كان هناك خطأ من الخادم (4xx, 5xx)
      else {
        if (decoded is Map<String, dynamic>) {
          result['message'] = decoded['message'] ?? decoded['error'] ?? 'Server error';
          print('❌ [API] Server Error: ${result['message']}');
        } else {
          result['message'] = 'Server Error (${response.statusCode})';
          print('❌ [API] HTTP Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      // 🛑 لو فشل التحليل (نص فاضي أو رد غير JSON)
      print('⚠️ [API] JSON Parse Error: $e');
      print('⚠️ [API] Raw response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      result['message'] = 'Failed to parse response: $e';
    }

    return result;
  }

  // ============================================================
  // ❌ معالجة الأخطاء
  // ============================================================
  static Map<String, dynamic> _handleError(dynamic error) {
    print('❌❌❌ [API] NETWORK ERROR ❌❌❌');
    print('🔴 Error details: $error');
    print('🔴 Error type: ${error.runtimeType}');

    String errorMessage = 'Network error';
    if (error.toString().contains('SocketException')) {
      errorMessage = 'لا يمكن الاتصال بالخادم - تأكد من الاتصال بالإنترنت وأن الخادم يعمل';
    } else if (error.toString().contains('TimeoutException')) {
      errorMessage = 'انتهت مهلة الاتصال - الخادم بطيء جداً';
    } else {
      errorMessage = 'خطأ في الشبكة: ${error.toString()}';
    }

    return {
      'success': false,
      'statusCode': 0,
      'data': null,
      'message': errorMessage,
    };
  }

  // ============================================================
  // 🖼️ POST مع ملف (Multipart) - لرفع الصور والملفات
  // ============================================================
  static Future<Map<String, dynamic>> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    String? filePath,
    String fileFieldName = 'image',  // ✅ تأكد أن اسم الحقل 'image' وليس 'file'
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final request = http.MultipartRequest('POST', uri);

      final token = await getToken();
      request.headers['Accept'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);

      if (filePath != null && filePath.isNotEmpty) {
        final file = await http.MultipartFile.fromPath(fileFieldName, filePath);
        request.files.add(file);
        print('📎 Attached file: $filePath');
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final decoded = json.decode(responseBody);

      // ✅ طباعة الاستجابة كاملة للتصحيح
      print('📊 Response: $responseBody');

      return {
        'success': streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300,
        'data': decoded,
        'statusCode': streamedResponse.statusCode,
      };
    } catch (e) {
      print('❌ Upload error: $e');
      return {
        'success': false,
        'message': 'Upload failed: $e',
      };
    }
  }

  // 📄 lib/services/api_service.dart
// أضف هذه الدوال داخل class ApiService

  // ============================================================
  // 🔄 تجديد التوكن (Refresh Token)
  // ============================================================
  static Future<bool> refreshToken() async {
    try {
      print('🔄 [API] محاولة تجديد التوكن...');

      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        print('❌ [API] لا يوجد Refresh Token');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      ).timeout(const Duration(seconds: 30));

      print('📊 [API] Refresh Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['access'];

        if (newAccessToken != null) {
          await prefs.setString('access_token', newAccessToken);
          print('✅ [API] تم تجديد التوكن بنجاح');
          return true;
        }
      }

      print('❌ [API] فشل تجديد التوكن');
      return false;
    } catch (e) {
      print('❌ [API] خطأ في تجديد التوكن: $e');
      return false;
    }
  }

  // ============================================================
  // 🔄 تسجيل الخروج وحذف التوكنات
  // ============================================================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    print('🚪 [API] تم تسجيل الخروج وحذف التوكنات');
  }
}