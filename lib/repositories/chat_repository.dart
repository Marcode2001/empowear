// 📄 lib/repositories/chat_repository.dart
// ============================================================
// 💬 مستودع المحادثات - متوافق مع API الخاص بك
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_models.dart';
import '../services/api_service.dart';

class ChatRepository {

  // ============================================================
  // 📥 1. تحميل قائمة المحادثات للطالب
  // ============================================================
  Future<List<ChatConversation>> loadConversations(String userId) async {
    try {
      final response = await ApiService.get(
        endpoint: 'conversation/trainee-my-conversations/',
        requireAuth: true,
      );

      print('📊 [ChatRepo] تحميل المحادثات - Status: ${response['statusCode']}');
      print('📊 [ChatRepo] البيانات: ${response['data']}');

      if (response['success']) {
        final List<dynamic> data = response['data'] is List ? response['data'] : [];
        return data.map((json) => ChatConversation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [ChatRepo] خطأ في تحميل المحادثات: $e');
      return [];
    }
  }

  // ============================================================
  // 📥 2. تحميل رسائل محادثة معينة
  // ============================================================
  Future<List<ChatMessage>> loadMessages(String userId, String conversationId) async {
    try {
      final response = await ApiService.get(
        endpoint: 'conversation/trainee-search-by-id/$conversationId/',
        requireAuth: true,
      );

      print('📊 [ChatRepo] تحميل الرسائل - Status: ${response['statusCode']}');
      print('📊 [ChatRepo] البيانات: ${response['data']}');

      if (response['success']) {
        final data = response['data'];
        // التحقق من وجود messages في الاستجابة
        if (data is Map<String, dynamic> && data['messages'] != null) {
          final List<dynamic> messages = data['messages'] is List ? data['messages'] : [];
          return messages.map((json) => ChatMessage.fromJson(json)).toList();
        } else if (data is List) {
          return data.map((json) => ChatMessage.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('❌ [ChatRepo] خطأ في تحميل الرسائل: $e');
      return [];
    }
  }

  // ============================================================
  // 📤 3. إرسال رسالة جديدة (كطالب)
  // ============================================================
  Future<bool> sendMessage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String message,
    String? imageUrl,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: 'conversation/trainee-create/',
        data: {
          'related_course': int.tryParse(receiverId) ?? 0, // ✅ إرسال معرف الكورس
          'content': message,  // ✅ محتوى الرسالة
        },
        requireAuth: true,
      );

      print('📊 [ChatRepo] إرسال رسالة - Status: ${response['statusCode']}');
      print('📊 [ChatRepo] الرد: ${response['data']}');

      return response['success'];
    } catch (e) {
      print('❌ [ChatRepo] خطأ في إرسال الرسالة: $e');
      return false;
    }
  }

  // ============================================================
  // 👨‍🏫 4. إرسال رسالة كمدرب
  // ============================================================
  Future<bool> sendMessageAsTrainer({
    required int conversationId,
    required String content,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: 'conversation/trainer-create/',
        data: {
          'conversation': conversationId,
          'content': content,
        },
        requireAuth: true,
      );

      print('📊 [ChatRepo] إرسال رسالة كمدرب - Status: ${response['statusCode']}');
      return response['success'];
    } catch (e) {
      print('❌ [ChatRepo] خطأ: $e');
      return false;
    }
  }

  // ============================================================
  // 👨‍🏫 5. جلب محادثات المدرب
  // ============================================================
  Future<List<ChatConversation>> getTrainerConversations() async {
    try {
      final response = await ApiService.get(
        endpoint: 'conversation/trainer-my-conversations/',
        requireAuth: true,
      );

      print('📊 [ChatRepo] تحميل محادثات المدرب - Status: ${response['statusCode']}');

      if (response['success']) {
        final List<dynamic> data = response['data'] is List ? response['data'] : [];
        return data.map((json) => ChatConversation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [ChatRepo] خطأ: $e');
      return [];
    }
  }

  // ============================================================
  // 🆕 6. إنشاء محادثة جديدة
  // ============================================================
  Future<Map<String, dynamic>> createConversation(int courseId) async {
    final response = await ApiService.post(
      endpoint: 'conversation/trainee-create/',
      data: {'related_course': courseId},
      requireAuth: true,
    );
    return response;
  }

  // ============================================================
  // 👁️ 7. تحديث حالة القراءة (اختياري)
  // ============================================================
  Future<bool> markMessagesAsRead(String userId, String otherUserId) async {
    // الـ API الحالي قد لا يدعم هذه الميزة
    return true;
  }

  // ============================================================
  // 🗑️ 8. مسح محادثة
  // ============================================================
  Future<bool> clearConversation(String userId, String otherUserId) async {
    final response = await ApiService.delete(
      endpoint: 'conversation/trainee-delete/$otherUserId/',
      requireAuth: true,
    );
    return response['success'];
  }

  // ============================================================
  // 💾 حفظ الرسائل في SharedPreferences (للتخزين المحلي)
  // ============================================================
  Future<void> saveMessages(String userId, String otherUserId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_messages_${userId}_$otherUserId';
    final jsonData = messages.map((m) => m.toJson()).toList();
    await prefs.setString(key, json.encode(jsonData));
  }

  // ============================================================
  // 💾 حفظ المحادثات في SharedPreferences
  // ============================================================
  Future<void> saveConversations(String userId, List<ChatConversation> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_conversations_$userId';
    final jsonData = conversations.map((c) => c.toJson()).toList();
    await prefs.setString(key, json.encode(jsonData));
  }
}