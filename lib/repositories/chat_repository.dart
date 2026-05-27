// 📄 lib/repositories/chat_repository.dart
// ============================================================
// 💬 مستودع المحادثات - نسخة كاملة محدثة (مع int لـ conversationId)
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_models.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class ChatRepository {

  // ============================================================
  // 📥 1. تحميل قائمة المحادثات
  // ============================================================
  Future<List<ChatConversation>> loadConversations({
    required String userId,
    required UserType userType,
  }) async {
    try {
      final endpoint = userType == UserType.trainer
          ? 'conversation/trainer-my-conversations/'
          : 'conversation/trainee-my-conversations/';

      final response = await ApiService.get(endpoint: endpoint, requireAuth: true);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'] is List ? response['data'] : [];
        final conversations = data.map((json) => ChatConversation.fromJson(json)).toList();
        return await _updateLastMessages(conversations);
      }
      return [];
    } catch (e) {
      print('❌ [ChatRepo] loadConversations error: $e');
      return [];
    }
  }

  // ============================================================
  // 📥 2. تحميل رسائل محادثة معينة
  // ✅ التعديل: conversationId من String إلى int
  // ============================================================
  Future<List<ChatMessage>> loadMessages({
    required String userId,
    required int conversationId, // ✅ أصبح int
    required UserType userType,
  }) async {

    try {

      // ========================================================
      // ✅ تحديد الرابط حسب نوع المستخدم
      // ========================================================

      final endpoint = userType == UserType.trainer
          ? 'message/trainer-by-conversation/$conversationId/'  // ✅ int مباشرة
          : 'message/trainee-by-conversation/$conversationId/'; // ✅ int مباشرة

      print("📨 LOAD MESSAGES");
      print("👤 userType: $userType");
      print("🆔 conversationId: $conversationId");
      print("🌐 endpoint: $endpoint");

      // ========================================================
      // ✅ طلب البيانات من السيرفر
      // ========================================================

      final response = await ApiService.get(
        endpoint: endpoint,
        requireAuth: true,
      );

      print("📥 RESPONSE: $response");

      List<ChatMessage> apiMessages = [];

      // ========================================================
      // ✅ التأكد أن الطلب نجح
      // ========================================================

      if (response['success'] == true && response['data'] != null) {

        final data = response['data'];

        // ======================================================
        // ✅ الحالة 1: السيرفر يرجع messages داخل data
        // ======================================================

        if (data is Map<String, dynamic> &&
            data['messages'] != null &&
            data['messages'] is List) {

          print("✅ messages FOUND");

          apiMessages = (data['messages'] as List)
              .map((j) => ChatMessage.fromJson(j))
              .toList();
        }

        // ======================================================
        // ✅ الحالة 2: السيرفر يرجع رسالة واحدة فقط
        // ======================================================

        else if (data is Map<String, dynamic> && data.containsKey('content')) {

          print("✅ SINGLE MESSAGE FOUND");

          apiMessages = [ChatMessage.fromJson(data)];
        }

        // ======================================================
        // ✅ الحالة 3: السيرفر يرجع List مباشرة
        // ======================================================

        else if (data is List) {

          print("✅ DIRECT LIST FOUND");

          apiMessages = data.map((j) => ChatMessage.fromJson(j)).toList();
        }

        else {
          print("⚠️ NO MESSAGES INSIDE RESPONSE");
        }
      }

      print("✅ API Messages Count: ${apiMessages.length}");

      // ========================================================
      // ✅ تحميل الرسائل المحلية (تحويل conversationId إلى String للمفتاح)
      // ========================================================

      final localMessages = await _loadLocalMessages(conversationId.toString());

      print("💾 Local Messages Count: ${localMessages.length}");

      // ========================================================
      // ✅ دمج الرسائل
      // ========================================================

      final allMessages = _mergeAndSort(apiMessages, localMessages);

      print("📦 Final Messages Count: ${allMessages.length}");

      return allMessages;

    } catch (e) {

      print('❌ [ChatRepo] loadMessages error: $e');

      return await _loadLocalMessages(conversationId.toString());
    }
  }

  // ============================================================
  // 📤 3. إرسال رسالة كطالب
  // ✅ التعديل: conversationId من String إلى int
  // ============================================================
  Future<bool> sendMessageAsTrainee({
    required int conversationId, // ✅ أصبح int
    required String message,
  }) async {

    try {

      print("👨‍🎓 TRAINEE SEND MESSAGE");
      print("🆔 conversationId: $conversationId");
      print("💬 message: $message");

      final response = await ApiService.post(
        endpoint: 'message/trainee-send/',
        data: {
          'conversation': conversationId, // ✅ int مباشرة
          'content': message,
        },
        requireAuth: true,
      );

      print("📥 Trainee Send Response: $response");

      return response['success'] == true;

    } catch (e) {

      print('❌ sendMessageAsTrainee ERROR: $e');
      return false;
    }
  }

  // ============================================================
  // 📤 4. إرسال رسالة كمدرب
  // ✅ التعديل: conversationId من String إلى int
  // ============================================================
  Future<bool> sendMessageAsTrainer({
    required int conversationId, // ✅ أصبح int
    required String content,
  }) async {

    try {

      print("👩‍🏫 TRAINER SEND MESSAGE");
      print("🆔 conversationId: $conversationId");
      print("💬 content: $content");

      final response = await ApiService.post(
        endpoint: 'message/trainer-send/',
        data: {
          'conversation': conversationId, // ✅ int مباشرة
          'content': content,
        },
        requireAuth: true,
      );

      print("📥 Trainer Send Response: $response");

      return response['success'] == true;

    } catch (e) {

      print('❌ sendMessageAsTrainer ERROR: $e');
      return false;
    }
  }

  // ============================================================
  // ✅ 5. تحديث حالة القراءة
  // ============================================================
  Future<bool> markMessagesAsRead(String userId, String otherUserId) async {
    try {
      final response = await ApiService.post(
        endpoint: 'conversation/mark-read/',
        data: {
          'user_id': userId,
          'other_user_id': otherUserId,
        },
        requireAuth: true,
      );
      return response['success'] == true;
    } catch (e) {
      print('❌ [ChatRepo] markMessagesAsRead error: $e');
      return false;
    }
  }

  // ============================================================
  // 🆕 6. إنشاء محادثة جديدة (للطالب)
  // ============================================================
  Future<Map<String, dynamic>> createConversationForTrainee(int courseId) async {
    return await ApiService.post(
      endpoint: 'conversation/trainee-create/',
      data: {'related_course': courseId},
      requireAuth: true,
    );
  }

  // ============================================================
  // 💾 دوال التخزين المحلي
  // ============================================================

  /// تحميل الرسائل من SharedPreferences
  Future<List<ChatMessage>> _loadLocalMessages(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_messages_$conversationId';
      final saved = prefs.getString(key);

      if (saved != null && saved.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(saved);
        return decoded.map((j) => ChatMessage.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      print('⚠️ [ChatRepo] _loadLocalMessages error: $e');
      return [];
    }
  }

  /// دمج وفرز الرسائل
  List<ChatMessage> _mergeAndSort(List<ChatMessage> api, List<ChatMessage> local) {
    final Map<String, ChatMessage> unique = {};
    for (var m in api) unique[m.id] = m;
    for (var m in local) if (!unique.containsKey(m.id)) unique[m.id] = m;
    final all = unique.values.toList();
    all.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return all;
  }

  /// تحديث آخر رسالة في قائمة المحادثات
  Future<List<ChatConversation>> _updateLastMessages(List<ChatConversation> convs) async {
    final prefs = await SharedPreferences.getInstance();
    return convs.map((conv) {
      final key = 'chat_messages_${conv.id}';
      final saved = prefs.getString(key);
      String lastMsg = conv.lastMessage;

      if (saved != null && saved.isNotEmpty) {
        try {
          final decoded = jsonDecode(saved);
          if (decoded is List && decoded.isNotEmpty) {
            lastMsg = decoded.last['content']?.toString() ??
                decoded.last['message']?.toString() ??
                conv.lastMessage;
          }
        } catch (_) {}
      }

      return ChatConversation(
        id: conv.id,
        relatedCourse: conv.relatedCourse,
        courseTitle: conv.courseTitle,
        trainerProfile: conv.trainerProfile,
        trainerFullName: conv.trainerFullName,
        traineeProfile: conv.traineeProfile,
        traineeFullName: conv.traineeFullName,
        isActive: conv.isActive,
        lastMessage: lastMsg,
        updatedAt: conv.updatedAt,
        unreadCount: conv.unreadCount,
      );
    }).toList();
  }
}