// 📄 lib/repositories/ai_repository.dart
// ============================================================
// 🤖 AI Repository - مسؤول عن الاتصال مع الخادم الخلفي
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AIRepository {
  // ============================================================
  // 🎨 Generate AI Design (CV + NLP Combined)
  // يستخدم عندما يكون هناك صورة + نص معاً
  // ============================================================
  Future<Map<String, dynamic>> generateDesign({
    required String traineeId,
    required String season,
    required String text,
    String? imagePath,
  }) async {
    final response = await ApiService.postMultipart(
      endpoint: 'ai/design/',
      fields: {
        'trainee_id': traineeId,
        'text': text,
        'season': season,
      },
      filePath: imagePath,
      fileFieldName: 'image',
      requireAuth: true,
    );
    return response;
  }

  // ============================================================
  // 📝 Generate NLP Design - للنص فقط
  // ============================================================
  Future<Map<String, dynamic>> generateNLPDesign({
    required String traineeId,
    required String season,
    required String text,
  }) async {
    final uri = Uri.parse('http://localhost:8000/api/api/ai/nlp/');
    final response = await http.post(
      uri,
      body: {
        'trainee_id': traineeId,
        'season': season,
        'text': text,
      },
    );
    return jsonDecode(response.body);
  }

  // ============================================================
  // 🔬 YOLO - Object Detection for Fabric/Material Analysis
  // ============================================================
  Future<Map<String, dynamic>> analyzeFabricWithYOLO({
    required int traineeId,
    required String imagePath,
  }) async {
    final response = await ApiService.postMultipart(
      endpoint: 'ai/yolo/',
      fields: {
        'trainee_id': traineeId.toString(),
      },
      filePath: imagePath,
      fileFieldName: 'image',
      requireAuth: true,
    );
    return response;
  }

  // ============================================================
  // 📊 Get YOLO Results History
  // ============================================================
  Future<Map<String, dynamic>> getYOLOResults({
    required int traineeId,
  }) async {
    final response = await ApiService.get(
      endpoint: 'ai/yolo/results/',
      queryParams: {'trainee_id': traineeId.toString()},
      requireAuth: true,
    );
    return response;
  }

  // ============================================================
  // 👁️ CV - Computer Vision Analysis (للصورة فقط)
  // هذا الـ endpoint يرجع 3D model + تحليلات
  // ============================================================
  Future<Map<String, dynamic>> analyzeFabricWithCV({
    required int traineeId,
    required String season,
    required String imagePath,
  }) async {
    final response = await ApiService.postMultipart(
      endpoint: 'ai/cv/',
      fields: {
        'trainee_id': traineeId.toString(),
        'season': season,
      },
      filePath: imagePath,
      fileFieldName: 'image',
      requireAuth: true,
    );
    return response;
  }

  // ============================================================
  // 📝 NLP - Process Text Description (للنص فقط)
  // هذا الـ endpoint يرجع ألوان وتحليلات نصية
  // ============================================================
  Future<Map<String, dynamic>> processText({
    required int traineeId,
    required String text,
    required String season,
  }) async {
    final response = await ApiService.post(
      endpoint: 'ai/nlp/',
      data: {
        'trainee_id': traineeId,
        'text': text,
        'season': season,
      },
      requireAuth: true,
    );
    return response;
  }

  // ============================================================
  // 📋 Get NLP Results
  // ============================================================
  Future<Map<String, dynamic>> getNLPResults({
    required int traineeId,
  }) async {
    final response = await ApiService.get(
      endpoint: 'ai/nlp/results/',
      queryParams: {'trainee_id': traineeId.toString()},
      requireAuth: true,
    );
    return response;
  }

  // ============================================================
  // 📋 Get CV Results
  // ============================================================
  Future<Map<String, dynamic>> getCVResults({
    required int traineeId,
  }) async {
    final response = await ApiService.get(
      endpoint: 'ai/cv/results/',
      queryParams: {'trainee_id': traineeId.toString()},
      requireAuth: true,
    );
    return response;
  }

  // ============================================================
  // 📋 Get Combined Design Results
  // ============================================================
  Future<Map<String, dynamic>> getDesignResults({
    required int traineeId,
  }) async {
    final response = await ApiService.get(
      endpoint: 'ai/design/results/',
      queryParams: {'trainee_id': traineeId.toString()},
      requireAuth: true,
    );
    return response;
  }
}