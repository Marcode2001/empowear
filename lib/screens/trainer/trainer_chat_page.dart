// 📄 lib/screens/trainer/trainer_chat_page.dart
// ============================================================
// 💬 صفحة المحادثة للمدرب - (قائمة المحادثات + تفاصيل المحادثة في صفحة واحدة)
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../repositories/chat_repository.dart';
import '../../models/chat_models.dart';

// ============================================================
// 📋 صفحة قائمة المحادثات الرئيسية للمدرب
// ============================================================

class TrainerChatPage extends StatefulWidget {
  const TrainerChatPage({super.key});

  @override
  State<TrainerChatPage> createState() => _TrainerChatPageState();
}

class _TrainerChatPageState extends State<TrainerChatPage> {
  String _searchQuery = '';
  List<ChatConversation> _conversations = [];
  bool _isLoading = true;
  final ChatRepository _chatRepo = ChatRepository();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    final convs = await _chatRepo.getTrainerConversations();
    setState(() {
      _conversations = convs;
      _isLoading = false;
    });
  }

  List<ChatConversation> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;
    return _conversations.where((conv) {
      return conv.otherUserName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // 🔍 حقل البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // 📋 قائمة المحادثات
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                : _filteredConversations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              itemCount: _filteredConversations.length,
              itemBuilder: (context, index) {
                final conversation = _filteredConversations[index];
                return _buildConversationCard(conversation);
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'When students message you, they will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(ChatConversation conversation) {
    final isUnread = conversation.unreadCount > 0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _ChatDetailPage(
              conversationId: conversation.id,
              studentName: conversation.otherUserName,
              studentId: conversation.otherUserId,
              courseName: conversation.courseName ?? '',
            ),
          ),
        );
        _loadConversations(); // إعادة تحميل بعد العودة
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.deepPurple.withOpacity(0.1),
            child: Text(
              conversation.otherUserName.isNotEmpty
                  ? conversation.otherUserName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple
              ),
            ),
          ),
          title: Text(
            conversation.otherUserName,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            conversation.lastMessage,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
            ),
            maxLines: 1,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(conversation.lastMessageTime),
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
              const SizedBox(height: 4),
              if (isUnread)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

// ============================================================
// 💬 صفحة تفاصيل المحادثة (داخل نفس الملف)
// ============================================================

class _ChatDetailPage extends StatefulWidget {
  final int conversationId;
  final String studentName;
  final String studentId;
  final String courseName;

  const _ChatDetailPage({
    required this.conversationId,
    required this.studentName,
    required this.studentId,
    required this.courseName,
  });

  @override
  State<_ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<_ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  final ChatRepository _chatRepo = ChatRepository();

  @override
  void initState() {
    super.initState();
    _loadMessagesFromStorage();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    });
  }

  // تحميل الرسائل من التخزين المحلي
  Future<void> _loadMessagesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_trainer_${widget.studentId}';
      final saved = prefs.getString(key);

      setState(() {
        if (saved != null && saved.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(saved);
          _messages = decoded.map((item) {
            return {
              'text': item['text'] as String,
              'isMe': item['isMe'] as bool,
              'createdAt': item['createdAt'] as String?,
            };
          }).toList();
        } else {
          _messages = [];
        }
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error loading messages: $e');
      setState(() {
        _isLoading = false;
        _messages = [];
      });
    }
  }

  // حفظ الرسائل في التخزين المحلي
  Future<void> _saveMessagesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_trainer_${widget.studentId}';
      final List<Map<String, dynamic>> toSave = _messages.map((msg) {
        return {
          'text': msg['text'],
          'isMe': msg['isMe'],
          'createdAt': msg['createdAt'],
        };
      }).toList();
      await prefs.setString(key, jsonEncode(toSave));
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  // إرسال رسالة جديدة
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    // إضافة الرسالة محلياً أولاً
    final newMessage = {
      'text': text,
      'isMe': true,
      'createdAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    _saveMessagesToStorage();
    _scrollToBottom();

    // إرسال إلى API
    final success = await _chatRepo.sendMessageAsTrainer(
      conversationId: widget.conversationId,
      content: text,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isSending = false;
    });

    _focusNode.requestFocus();
  }

  // مسح المحادثة بالكامل
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
      await _saveMessagesToStorage();

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

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _saveMessagesToStorage();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.deepPurple.shade300,
              child: Text(
                widget.studentName.isNotEmpty ? widget.studentName[0].toUpperCase() : '?',
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
                  widget.studentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.courseName,
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
      body: Column(
        children: [
          Expanded(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                  ? _buildEmptyChatState()
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
          AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: _buildInputBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState() {
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
            'Start the conversation with ${widget.studentName}',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

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
                      : const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                  ),
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