// lib/repositories/chat_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_models.dart';
import '../services/api_service.dart';

class ChatRepository {

  // ============================================================
  // 📥 1. تحميل قائمة المحادثات
  // ============================================================
  Future<List<ChatConversation>> loadConversations(String userId) async {
    final response = await ApiService.get(
      endpoint: 'conversation/trainee-my-conversations/',  // ✅ Endpoint صحيح
      requireAuth: true,
    );

    if (response['success']) {
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ChatConversation.fromJson(json)).toList();
    }
    return [];
  }

  // ============================================================
  // 📥 2. تحميل رسائل محادثة معينة
  // ============================================================
  Future<List<ChatMessage>> loadMessages(String userId, String otherUserId) async {
    final response = await ApiService.get(
      endpoint: 'conversation/trainee-search-by-id/$otherUserId/',  // ✅ باستخدام conversationId
      requireAuth: true,
    );

    if (response['success']) {
      final data = response['data'];
      final List<dynamic> messages = data['messages'] ?? [];
      return messages.map((json) => ChatMessage.fromJson(json)).toList();
    }
    return [];
  }

  // ============================================================
  // 📤 3. إرسال رسالة جديدة
  // ============================================================
  Future<bool> sendMessage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String message,
    String? imageUrl,
  }) async {
    final response = await ApiService.post(
      endpoint: 'conversation/send-message/',  // ✅ قد تحتاج لتأكيد هذا ال endpoint مع الباك
      data: {
        'conversation_id': receiverId,  // في الـ API حقك، المحادثة لها ID منفصل
        'message': message,
      },
      requireAuth: true,
    );
    return response['success'];
  }

  // ============================================================
  // 🆕 4. إنشاء محادثة جديدة
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
  // 👁️ 5. تحديث حالة القراءة
  // ============================================================
  Future<bool> markMessagesAsRead(String userId, String otherUserId) async {
    // ⚠️ الـ API الحالي قد لا يدعم هذه الميزة
    return true;
  }

  // ============================================================
  // 🗑️ 6. مسح محادثة
  // ============================================================
  Future<bool> clearConversation(String userId, String otherUserId) async {
    final response = await ApiService.delete(
      endpoint: 'conversation/trainee-delete/$otherUserId/',
      requireAuth: true,
    );
    return response['success'];

    // lib/repositories/chat_repository.dart
// أضيفي هذه الدوال داخل class ChatRepository

    // 💾 حفظ الرسائل في SharedPreferences (للتخزين المحلي)
    Future<void> saveMessages(String userId, String otherUserId, List<ChatMessage> messages) async {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_messages_${userId}_$otherUserId';
      final jsonData = messages.map((m) => m.toJson()).toList();
      await prefs.setString(key, json.encode(jsonData));
    }

    // 💾 حفظ المحادثات في SharedPreferences
    Future<void> saveConversations(String userId, List<ChatConversation> conversations) async {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_conversations_$userId';
      final jsonData = conversations.map((c) => c.toJson()).toList();
      await prefs.setString(key, json.encode(jsonData));
    }
  }
}