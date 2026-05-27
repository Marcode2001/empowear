// 📄 lib/models/chat_models.dart
// ============================================================
// 💬 نماذج المحادثات - مع دوال مساعدة موحدة
// ============================================================

import 'package:flutter/material.dart';
import 'user_model.dart'; // ✅ ضروري لتعريف UserType

// ============================================================
// 📝 نموذج الرسالة
// ============================================================
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? courseId;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.courseId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: json['conversation_id']?.toString() ?? json['conversation']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? json['sender']?.toString() ?? '',
      senderName: json['sender_name']?.toString() ?? json['senderName']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? json['receiver']?.toString() ?? '',
      receiverName: json['receiver_name']?.toString() ?? json['receiverName']?.toString() ?? '',
      message: json['content']?.toString() ?? json['message']?.toString() ?? '',
      timestamp: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'])
          : (json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now()),
      isRead: json['is_read'] ?? false,
      imageUrl: json['image_url']?.toString(),
      courseId: json['course_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'receiver_id': receiverId,
      'receiver_name': receiverName,
      'content': message,
      'sent_at': timestamp.toIso8601String(),
      'is_read': isRead,
      'image_url': imageUrl,
      'course_id': courseId,
    };
  }
}

// ============================================================
// 💬 نموذج المحادثة - مع الدوال الموحدة ✅
// ============================================================
class ChatConversation {
  final int id;
  final int relatedCourse;
  final String courseTitle;
  final int trainerProfile;      // ✅ معرف المدرب من الباك إند
  final int traineeProfile;      // ✅ معرف الطالب من الباك إند
  final String? trainerFullName;
  final String? traineeFullName;
  final bool isActive;

  String lastMessage;
  DateTime updatedAt;
  int unreadCount;

  ChatConversation({
    required this.id,
    required this.relatedCourse,
    required this.courseTitle,
    required this.trainerProfile,
    this.trainerFullName,
    required this.traineeProfile,
    this.traineeFullName,
    required this.isActive,
    this.lastMessage = 'No messages yet',
    DateTime? updatedAt,
    this.unreadCount = 0,
  }) : updatedAt = updatedAt ?? DateTime.now();

  // ============================================================
  // ✅ ✅ ✅ الدوال الموحدة - السر في حل مشكلة التزامن ✅ ✅ ✅
  // ============================================================

  /// 🔑 مفتاح موحد للتخزين المحلي - يعمل للطرفين بنفس القيمة!
  String get storageKey {
    // نرتب المعرفات تصاعدياً لضمان أن المفتاح واحد دائماً
    final ids = [trainerProfile, traineeProfile]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }

  /// ✅ الحصول على اسم الطرف الآخر بناءً على نوع المستخدم
  String getPartnerName(UserType myType) {
    if (myType == UserType.trainee) {
      return trainerFullName?.isNotEmpty == true ? trainerFullName! : 'مدرب';
    } else if (myType == UserType.trainer) {
      return traineeFullName?.isNotEmpty == true ? traineeFullName! : 'طالب';
    }
    return 'مستخدم';
  }

  /// ✅ الحصول على معرف الطرف الآخر
  String getPartnerId(UserType myType) {
    if (myType == UserType.trainee) {
      return trainerProfile.toString();
    } else if (myType == UserType.trainer) {
      return traineeProfile.toString();
    }
    return '';
  }

  /// ✅ Getter لعنوان الكورس
  String? get courseName => courseTitle.isNotEmpty ? courseTitle : null;

  // ============================================================
  // من/إلى JSON
  // ============================================================
  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] ?? 0,
      relatedCourse: json['related_course'] ?? 0,
      courseTitle: json['course_title']?.toString() ?? '',
      trainerProfile: json['trainer_profile'] ?? 0,
      trainerFullName: json['trainer_full_name']?.toString(),
      traineeProfile: json['trainee_profile'] ?? 0,
      traineeFullName: json['trainee_full_name']?.toString(),
      isActive: json['is_active'] ?? true,
      lastMessage: json['last_message']?.toString() ?? 'No messages yet',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'related_course': relatedCourse,
      'course_title': courseTitle,
      'trainer_profile': trainerProfile,
      'trainer_full_name': trainerFullName,
      'trainee_profile': traineeProfile,
      'trainee_full_name': traineeFullName,
      'is_active': isActive,
      'last_message': lastMessage,
      'updated_at': updatedAt.toIso8601String(),
      'unread_count': unreadCount,
    };
  }
}