// 📄 lib/services/api_service.dart
// ============================================================
// 🌐 خدمة الـ API الأساسية للتواصل مع الباك إند
// ============================================================
// الوظيفة: إدارة جميع طلبات الشبكة
// - إعداد الهيدرز (التوثيق، نوع المحتوى)
// - معالجة الاستجابات والأخطاء
// - دعم تجديد التوكن تلقائياً
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  // 🌐 رابط الـ API الأساسي
  // ⚠️ مهم: غيّر هذا العنوان حسب جهازك أو السيرفر الفعلي
  static const String baseUrl = 'http://192.168.1.22:8000/api';

  // ⏱️ مهلة الانتظار للطلبات (بالثواني)
  static const int timeoutSeconds = 30;

  // ============================================================
  // 🔑 دوال إدارة التوكنات
  // ============================================================

  /// ✅ الحصول على توكن الوصول من التخزين المحلي
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// ✅ الحصول على ريفرش توكن من التخزين المحلي
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  /// ✅ حفظ التوكنات بعد تسجيل الدخول الناجح
  /// 📌 استخدم هذه الدالة في AuthRepository بعد استلام رد الـ login
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    print('✅ [API] تم حفظ التوكنات بنجاح');
  }

  /// ✅ حذف التوكنات عند تسجيل الخروج
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    print('🚪 [API] تم حذف التوكنات (تسجيل خروج)');
  }

  // ============================================================
  // 📝 إعداد الهيدرز للطلبات
  // ============================================================

  /// ✅ إنشاء الهيدرز المطلوبة للطلبات
  static Future<Map<String, String>> _buildHeaders({bool requireAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ============================================================
  // 🔄 تجديد التوكن (Refresh Token)
  // ============================================================

  /// ✅ محاولة تجديد التوكن باستخدام الـ refresh_token
  static Future<bool> _refreshAccessToken() async {
    try {
      print('🔄 [API] محاولة تجديد التوكن...');

      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ [API] لا يوجد Refresh Token - يجب تسجيل الدخول مجدداً');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['access'];

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', newAccessToken);
          print('✅ [API] تم تجديد التوكن بنجاح');
          return true;
        }
      }

      print('❌ [API] فشل تجديد التوكن - الكود: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ [API] خطأ أثناء تجديد التوكن: $e');
      return false;
    }
  }

  // ============================================================
  // 📄 معالجة الاستجابة من الخادم
  // ============================================================

  /// ✅ تحليل واستخراج البيانات من استجابة الـ HTTP
  static Map<String, dynamic> _parseResponse(http.Response response) {
    final result = {
      'success': false,
      'statusCode': response.statusCode,
      'data': null,
      'message': '',
    };

    // 🔹 إذا كان الجسم فارغاً
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        result['success'] = true;
        result['message'] = 'Success';
      } else {
        result['message'] = 'Empty response from server';
      }
      return result;
    }

    try {
      // 🔹 محاولة تحليل الجسم كـ JSON
      final dynamic decoded = json.decode(response.body);

      // 🔹 إذا كان الرد ناجحاً (2xx)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        result['success'] = true;
        result['data'] = decoded;

        if (decoded is Map<String, dynamic>) {
          result['message'] = decoded['message'] ?? decoded['detail'] ?? 'Success';
        } else if (decoded is List) {
          result['message'] = 'Success - ${decoded.length} items';
        } else {
          result['message'] = 'Success';
        }
      }
      // 🔹 إذا كان هناك خطأ من الخادم (4xx, 5xx)
      else {
        if (decoded is Map<String, dynamic>) {
          result['message'] = decoded['message'] ??
              decoded['detail'] ??
              decoded['error'] ??
              'Server error (${response.statusCode})';
        } else {
          result['message'] = 'Server error (${response.statusCode})';
        }
      }
    } catch (e) {
      // 🔹 إذا فشل التحليل (مثل استقبال HTML بدلاً من JSON)
      print('⚠️ [API] فشل تحليل JSON: $e');

      // 🔹 إذا كان الرد HTML (صفحة خطأ 404 مثلاً)
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        result['message'] = 'Server returned HTML instead of JSON (Endpoint may not exist)';
        result['data'] = {'html_response': true};
      } else {
        result['message'] = 'Failed to parse response: $e';
      }
    }

    return result;
  }

  // ============================================================
  // ❌ معالجة أخطاء الشبكة
  // ============================================================

  /// ✅ تحويل أخطاء الشبكة إلى رسالة مفهومة للمستخدم
  static Map<String, dynamic> _handleNetworkError(dynamic error) {
    print('❌ [API] Network Error: $error');

    String message;
    if (error is http.ClientException || error.toString().contains('SocketException')) {
      message = 'لا يمكن الاتصال بالخادم. تأكد من الإنترنت وعنوان السيرفر.';
    } else if (error.toString().contains('TimeoutException')) {
      message = 'انتهت مهلة الاتصال. الخادم يستجيب ببطء.';
    } else if (error.toString().contains('HttpException')) {
      message = 'خطأ في بروتوكول الاتصال مع الخادم.';
    } else {
      message = 'حدث خطأ غير متوقع: ${error.toString()}';
    }

    return {
      'success': false,
      'statusCode': 0,
      'data': null,
      'message': message,
    };
  }

  // ============================================================
  // 📥 طلب GET
  // ============================================================

  static Future<Map<String, dynamic>> get({
    required String endpoint,
    bool requireAuth = true,
    Map<String, String>? queryParams,
    int retryCount = 0,
  }) async {
    try {

      // ========================================================
      // 🔹 بناء رابط الـ API
      // ========================================================
      var uri = Uri.parse('$baseUrl/$endpoint');

      // ✅ إذا في Query Params نضيفها للرابط
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      // ========================================================
      // 🔹 تجهيز Headers
      // ========================================================
      final headers = await _buildHeaders(
        requireAuth: requireAuth,
      );

      // ========================================================
      // 🔹 إرسال الطلب
      // ========================================================
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(
        const Duration(seconds: timeoutSeconds),
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      // ========================================================
      // ✅ طباعة معلومات الطلب للتصحيح
      // ========================================================
      print('');
      print('🌐 ================================');
      print('🌐 API GET REQUEST');
      print('🌐 URL: $uri');
      print('🌐 STATUS CODE: ${response.statusCode}');
      print('🌐 RESPONSE BODY:');
      print(response.body);
      print('🌐 ================================');
      print('');

      // ========================================================
      // 🔹 إذا التوكن منتهي (401)
      // ========================================================
      if (response.statusCode == 401 &&
          requireAuth &&
          retryCount == 0) {

        print('🔄 [API] التوكن منتهي - محاولة تجديد');

        final refreshed = await _refreshAccessToken();

        // ✅ إذا نجح التجديد نعيد الطلب
        if (refreshed) {

          return await get(
            endpoint: endpoint,
            requireAuth: requireAuth,
            queryParams: queryParams,
            retryCount: 1,
          );

        } else {

          // ❌ إذا فشل التجديد
          await clearTokens();

          return {
            'success': false,
            'statusCode': 401,
            'data': null,
            'message':
            'انتهت جلسة المستخدم. يرجى تسجيل الدخول مجدداً.',
          };
        }
      }

      // ========================================================
      // ✅ تحليل الاستجابة وإرجاعها
      // ========================================================
      return _parseResponse(response);

    } catch (e) {

      // ❌ معالجة أخطاء الشبكة
      return _handleNetworkError(e);
    }
  }

  // ============================================================
  // 📤 طلب POST
  // ============================================================

  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> data,
    bool requireAuth = true,
    int retryCount = 0,  // ✅ تم إزالة الشرطة السفلية
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final headers = await _buildHeaders(requireAuth: requireAuth);

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: timeoutSeconds));
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      // 🔹 معالجة حالة 401
      if (response.statusCode == 401 && requireAuth && retryCount == 0) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return await post(
            endpoint: endpoint,
            data: data,
            requireAuth: requireAuth,
            retryCount: 1,  // ✅ تم إزالة الشرطة السفلية
          );
        } else {
          await clearTokens();
          return {
            'success': false,
            'statusCode': 401,
            'data': null,
            'message': 'انتهت جلسة المستخدم. يرجى تسجيل الدخول مجدداً.',
          };
        }
      }

      return _parseResponse(response);
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // ============================================================
  // ✏️ طلب PUT
  // ============================================================

  static Future<Map<String, dynamic>> put({
    required String endpoint,
    required Map<String, dynamic> data,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final headers = await _buildHeaders(requireAuth: requireAuth);

      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: timeoutSeconds));

      return _parseResponse(response);
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // ============================================================
  // ✏️ طلب PATCH
  // ============================================================

  static Future<Map<String, dynamic>> patch({
    required String endpoint,
    required Map<String, dynamic> data,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final headers = await _buildHeaders(requireAuth: requireAuth);

      final response = await http.patch(
        uri,
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: timeoutSeconds));

      return _parseResponse(response);
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // ============================================================
  // 🗑️ طلب DELETE
  // ============================================================

  static Future<Map<String, dynamic>> delete({
    required String endpoint,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final headers = await _buildHeaders(requireAuth: requireAuth);

      final response = await http.delete(uri, headers: headers)
          .timeout(const Duration(seconds: timeoutSeconds));

      return _parseResponse(response);
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // ============================================================
  // 📎 طلب POST مع رفع ملف (Multipart)
  // ============================================================

  static Future<Map<String, dynamic>> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    String? filePath,
    String fileFieldName = 'image',
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // 🔹 إضافة الهيدرز
      request.headers['Accept'] = 'application/json';
      if (requireAuth) {
        final token = await getAccessToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      // 🔹 إضافة الحقول النصية
      request.fields.addAll(fields);

      // 🔹 إرفاق الملف إذا وُجد
      if (filePath != null && filePath.isNotEmpty) {
        final file = await http.MultipartFile.fromPath(
          fileFieldName,
          filePath,
          contentType: MediaType('image', 'jpeg'), // 🔥 هذا هو التعديل المهم
        );

        request.files.add(file);
        print('📎 [API] Attached file: $filePath');
      }

      // 🔹 إرسال الطلب
      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: timeoutSeconds));

      final responseBody = await streamedResponse.stream.bytesToString();

      // ✅ تحليل JSON بأمان بدون extension
      dynamic decoded;
      try {
        decoded = json.decode(responseBody);
      } catch (_) {
        decoded = null;
      }

      return {
        'success': streamedResponse.statusCode >= 200 &&
            streamedResponse.statusCode < 300,
        'statusCode': streamedResponse.statusCode,
        'data': decoded,
        'message': decoded is Map ? (decoded['message'] ?? 'Done') : 'Done',
      };
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // ============================================================
  // 🚪 تسجيل الخروج من التطبيق
  // ============================================================

  /// ✅ تسجيل الخروج وحذف جميع التوكنات
  static Future<void> logout() async {
    await clearTokens();
    print('✅ [API] تم تسجيل الخروج بنجاح');
  }

}
