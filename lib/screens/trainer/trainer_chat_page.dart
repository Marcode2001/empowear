// 📄 lib/screens/trainer/trainer_chat_detail_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TrainerChatDetailPage extends StatefulWidget {
  final String name;
  final String avatar;
  final String studentId;
  final Function(String, String, String)? onChatUpdated;

  const TrainerChatDetailPage({
    super.key,
    required this.name,
    required this.avatar,
    required this.studentId,
    this.onChatUpdated,
  });

  @override
  State<TrainerChatDetailPage> createState() => _TrainerChatDetailPageState();
}

class _TrainerChatDetailPageState extends State<TrainerChatDetailPage> {
  // متحكمات النص والتمرير
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // البيانات
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  // ✅ متغير لمعرفة ما إذا كان الكيبورد مفتوحاً
  bool _isKeyboardVisible = false;
  // ✅ ارتفاع الكيبورد
  double _keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    _loadMessages();

    // ✅ إضافة مستمع لظهور وإخفاء الكيبورد
    _focusNode.addListener(() {
      setState(() {
        _isKeyboardVisible = _focusNode.hasFocus;
      });

      // ✅ عند ظهور الكيبورد، نمرر لآخر رسالة
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    });
  }

  // تحميل الرسائل من التخزين
  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_${widget.studentId}';
      final saved = prefs.getString(key);

      setState(() {
        if (saved != null && saved.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(saved);
          _messages = decoded.map((item) {
            return {
              'text': item['text'] as String,
              'isMe': item['isMe'] as bool,
            };
          }).toList();
        } else {
          _messages = [];
        }
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        _isLoading = false;
        _messages = [];
      });
    }
  }

  // حفظ الرسائل في التخزين
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_${widget.studentId}';
      final List<Map<String, dynamic>> toSave = _messages.map((msg) {
        return {
          'text': msg['text'],
          'isMe': msg['isMe'],
        };
      }).toList();
      await prefs.setString(key, jsonEncode(toSave));
    } catch (e) {
      print('Error saving messages: $e');
    }
  }

  // ✅ دالة إرسال الرسالة (معدلة)
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    final newMessage = {
      'text': text,
      'isMe': true,
    };

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    _saveMessages();

    if (widget.onChatUpdated != null) {
      widget.onChatUpdated!(widget.studentId, text, '');
    }

    // ✅ تأخير صغير للتمرير بعد إضافة الرسالة
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });

    setState(() {
      _isSending = false;
    });

    // ✅ إبقاء التركيز على حقل النص (يبقي الكيبورد مفتوحاً)
    _focusNode.requestFocus();
  }

  // مسح كل الرسائل
  Future<void> _clearChat() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      setState(() {
        _messages.clear();
      });
      await _saveMessages();
      if (widget.onChatUpdated != null) {
        widget.onChatUpdated!(widget.studentId, 'Chat cleared', '');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat cleared'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ✅ دالة التمرير لآخر رسالة
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _saveMessages();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ الحصول على ارتفاع لوحة المفاتيح
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      // ❌ تعطيل خاصية التعديل التلقائي لأننا سنتحكم يدوياً
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.deepPurple.shade300,
              child: Text(
                widget.avatar.isNotEmpty ? widget.avatar[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Student',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Stack(
        children: [
          // ✅ الخلفية - قائمة الرسائل (تتحرك للأعلى عند ظهور الكيبورد)
          Positioned.fill(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              // ✅ عندما يظهر الكيبورد، نضيف padding سفلي بقدر ارتفاع الكيبورد
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(
                    message['text'] as String,
                    message['isMe'] as bool,
                  );
                },
              ),
            ),
          ),
          // ✅ شريط الكتابة (يثبت في الأسفل)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              // ✅ شريط الكتابة يتحرك للأعلى مع الكيبورد
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: _buildInputBar(),
            ),
          ),
        ],
      ),
    );
  }

  // صفحة فارغة (لا توجد رسائل)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // شريط كتابة الرسالة
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !_isSending,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isSending ? null : _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: _isSending
                      ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                      : const LinearGradient(colors: [Colors.deepPurple, Colors.purple]),
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // فقاعة الرسالة
  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isMe
                ? const LinearGradient(colors: [Colors.deepPurple, Colors.purple])
                : null,
            color: isMe ? null : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 8),
              bottomRight: Radius.circular(isMe ? 8 : 20),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}