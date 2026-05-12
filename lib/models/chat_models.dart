// 📄 lib/models/chat_models.dart
// ============================================================
// 💬 نماذج بيانات المحادثات - متوافقة مع API
// ============================================================

import 'package:flutter/material.dart';

// ============================================================
// 📝 نموذج الرسالة (Message)
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
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? json['conversation']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? json['sender']?.toString() ?? '',
      senderName: json['sender_name'] ?? json['senderName'] ?? '',
      receiverId: json['receiver_id']?.toString() ?? json['receiver']?.toString() ?? '',
      receiverName: json['receiver_name'] ?? json['receiverName'] ?? '',
      message: json['content'] ?? json['message'] ?? '',
      timestamp: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'])
          : (json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now()),
      isRead: json['is_read'] ?? false,
      imageUrl: json['image_url'],
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
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'image_url': imageUrl,
      'course_id': courseId,
    };
  }
}

// ============================================================
// 💬 نموذج المحادثة (Conversation) - متوافق مع الـ UI و API
// ============================================================
class ChatConversation {
  // حقول الـ API
  final int id;
  final int relatedCourse;
  final String courseTitle;
  final int trainerProfile;
  final String? trainerName;
  final int traineeProfile;
  final String? traineeName;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;

  // حقول للـ UI (محسوبة من الحقول أعلاه)
  String get otherUserId => trainerProfile.toString();
  String get otherUserName => trainerName ?? traineeName ?? '';
  String? get otherUserImage => null;
  DateTime get lastMessageTime => updatedAt;
  String? get courseId => relatedCourse.toString();
  String? get courseName => courseTitle;

  ChatConversation({
    required this.id,
    required this.relatedCourse,
    required this.courseTitle,
    required this.trainerProfile,
    this.trainerName,
    required this.traineeProfile,
    this.traineeName,
    required this.lastMessage,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] ?? 0,
      relatedCourse: json['related_course'] ?? 0,
      courseTitle: json['course_title'] ?? '',
      trainerProfile: json['trainer_profile'] ?? 0,
      trainerName: json['trainer_full_name'] ?? json['trainer_name'],
      traineeProfile: json['trainee_profile'] ?? 0,
      traineeName: json['trainee_full_name'] ?? json['trainee_name'],
      lastMessage: json['last_message'] ?? '',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
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
      'trainer_name': trainerName,
      'trainee_profile': traineeProfile,
      'trainee_name': traineeName,
      'last_message': lastMessage,
      'updated_at': updatedAt.toIso8601String(),
      'unread_count': unreadCount,
    };
  }
}