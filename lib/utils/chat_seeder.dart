//  lib/utils/chat_seeder.dart
// ============================================================
//  أداة لإنشاء محادثات ورسائل تجريبية
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatSeeder {

  // ✅ دالة لإنشاء محادثات ورسائل تجريبية للمدرب مروة
  static Future<void> seedChatsForTrainer() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ إنشاء رسائل للمحادثة
    final messages = [
      {
        'text': 'Hello Ms. Marwa, I have a question about the drawing assignment',
        'isMe': false,  // false = من الطالب
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'text': 'Of course Rama! What would you like to know?',
        'isMe': true,   // true = من المدرب
        'createdAt': DateTime.now().subtract(const Duration(hours: 4, minutes: 50)).toIso8601String(),
      },
      {
        'text': 'I\'m having trouble with the proportions of the model\'s body',
        'isMe': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 4, minutes: 40)).toIso8601String(),
      },
      {
        'text': 'Can you share your sketch so I can give you feedback?',
        'isMe': true,
        'createdAt': DateTime.now().subtract(const Duration(hours: 4, minutes: 30)).toIso8601String(),
      },
      {
        'text': 'Yes, I will upload it now. Thank you for your help!',
        'isMe': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 4, minutes: 25)).toIso8601String(),
      },
      {
        'text': 'You\'re welcome! I\'ll review it as soon as you upload',
        'isMe': true,
        'createdAt': DateTime.now().subtract(const Duration(hours: 4, minutes: 20)).toIso8601String(),
      },
    ];

    // ✅ حفظ الرسائل للتخزين المؤقت
    final key = 'chat_messages_1';  // conversationId = 1
    await prefs.setString(key, jsonEncode(messages));

    print('✅ [ChatSeeder] تم إنشاء محادثة تجريبية للمدرب مع الطالبة Rama');
    print('✅ [ChatSeeder] تم حفظ ${messages.length} رسالة');
  }

  // ✅ دالة لإنشاء محادثة للطالب راما
  static Future<void> seedChatForStudent() async {
    final prefs = await SharedPreferences.getInstance();

    final messages = [
      {
        'text': 'Hello Ms. Marwa, I have a question about the drawing assignment',
        'isMe': true,   // true = من الطالب
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'text': 'Of course Rama! What would you like to know?',
        'isMe': false,  // false = من المدرب
        'createdAt': DateTime.now().subtract(const Duration(hours: 4, minutes: 50)).toIso8601String(),
      },
      {
        'text': 'I\'m having trouble with the proportions of the model\'s body',
        'isMe': true,
        'createdAt': DateTime.now().subtract(const Duration(hours: 4, minutes: 40)).toIso8601String(),
      },
      {
        'text': 'Can you share your sketch so I can give you feedback?',
        'isMe': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 4, minutes: 30)).toIso8601String(),
      },
      {
        'text': 'Yes, I will upload it now. Thank you for your help!',
        'isMe': true,
        'createdAt': DateTime.now().subtract(const Duration(hours: 4, minutes: 25)).toIso8601String(),
      },
      {
        'text': 'You\'re welcome! I\'ll review it as soon as you upload',
        'isMe': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 4, minutes: 20)).toIso8601String(),
      },
    ];

    final key = 'chat_messages_1';
    await prefs.setString(key, jsonEncode(messages));

    print('✅ [ChatSeeder] تم إنشاء محادثة تجريبية للطالب Rama مع المدربة Marwa');
  }

  // ✅ دالة لتشغيل جميع الـ Seeder مرة واحدة
  static Future<void> runAll() async {
    await seedChatForStudent();
    await seedChatsForTrainer();
    print('✅ [ChatSeeder] تم إنشاء جميع المحادثات التجريبية بنجاح!');
  }
}