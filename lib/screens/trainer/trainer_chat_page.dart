// trainer_chat_page.dart
// ============================================================
// 📱 TRAINER CHAT PAGE - With Message Bubbles (Left/Right + Gradient)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../models/chat_models.dart';
import '../../models/user_model.dart';

// ============================================================
// 📋 CONVERSATIONS LIST - Trainer Side
// ============================================================

class TrainerChatPage extends StatefulWidget {
  @override
  State<TrainerChatPage> createState() => _TrainerChatPageState();
}

class _TrainerChatPageState extends State<TrainerChatPage> {
  @override
  void initState() {
    super.initState();
    // Load conversations after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthBloc>().state;
      if (auth is AuthAuthenticated) {
        context.read<ChatBloc>().add(
          LoadConversationsEvent(
            userId: auth.user.id,
            userType: UserType.trainer,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return const Center(
                child: Text('No conversations yet', style: TextStyle(color: Colors.grey)),
              );
            }
            return ListView.builder(
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conv = state.conversations[index];
                final studentName = conv.getPartnerName(UserType.trainer);
                final studentId = conv.getPartnerId(UserType.trainer);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(
                      studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                  title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    conv.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: conv.unreadCount > 0
                      ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${conv.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ) : null,
                  onTap: () async {
                    final authBloc = context.read<AuthBloc>();
                    final chatBloc = context.read<ChatBloc>();

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrainerChatDetailPage(
                          conversationId: conv.id,
                          studentName: studentName,
                          studentId: studentId,
                          courseName: conv.courseTitle,
                          relatedCourse: conv.relatedCourse,
                          storageKey: conv.storageKey,
                        ),
                      ),
                    );

                    final auth = authBloc.state;
                    if (auth is AuthAuthenticated) {
                      chatBloc.add(
                        LoadConversationsEvent(
                          userId: auth.user.id,
                          userType: UserType.trainer,
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ============================================================
// 💬 CHAT DETAIL PAGE - Trainer Side (With Message Bubbles)
// ============================================================

class TrainerChatDetailPage extends StatefulWidget {
  final int conversationId;
  final String studentName;
  final String studentId;
  final String? courseName;
  final int relatedCourse;
  final String storageKey;

  const TrainerChatDetailPage({
    super.key,
    required this.conversationId,
    required this.studentName,
    required this.studentId,
    this.courseName,
    required this.relatedCourse,
    required this.storageKey,
  });

  @override
  State<TrainerChatDetailPage> createState() => _TrainerChatDetailPageState();
}

class _TrainerChatDetailPageState extends State<TrainerChatDetailPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final FocusNode _focusNode = FocusNode(); // ✅ إضافة FocusNode
  List<ChatMessage> _msgs = [];
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load messages only once
    if (_loaded) return;

    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      _loaded = true;
      context.read<ChatBloc>().add(
        LoadMessagesEvent(
          userId: auth.user.id,
          conversationId: widget.conversationId,
          userType: UserType.trainer,
        ),
      );
    }
  }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<ChatBloc>().add(
        SendMessageEvent(
          conversationId: widget.conversationId,
          senderId: auth.user.id,
          senderName: auth.user.name,
          receiverId: widget.studentId,
          receiverName: widget.studentName,
          message: _ctrl.text.trim(),
          courseId: widget.relatedCourse.toString(),
          senderType: UserType.trainer,
        ),
      );
      _ctrl.clear();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Check if message is from current user (trainer)
  bool _isMyMessage(ChatMessage message) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return false;
    return message.senderId == auth.user.id;
  }

  // Build message bubble with gradient and rounded corners
  Widget _buildBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isMe
                ? [Colors.deepPurple, Colors.purple]
                : [Colors.grey.shade300, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 18),
          ),
        ),
        child: Text(
          message.message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 🎨 جعل اسم الطالب باللون الأبيض
        title: Text(
          widget.studentName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // 🏹 تغيير لون سهم الرجوع إلى الأبيض
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocListener<ChatBloc, ChatState>(
              listener: (ctx, state) {
                if (state is MessagesLoaded) {
                  setState(() {
                    _msgs = state.messages;
                    _msgs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                  });
                  _scrollToBottom();
                }
                if (state is MessageSent) {
                  setState(() {
                    _msgs.add(state.message);
                  });
                  _scrollToBottom();
                }
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: _msgs.isEmpty
                  ? const Center(
                child: Text('Start the conversation...', style: TextStyle(color: Colors.grey)),
              )
                  : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: _msgs.length,
                itemBuilder: (ctx, index) {
                  final message = _msgs[index];
                  final isMe = _isMyMessage(message);
                  return _buildBubble(message, isMe);
                },
              ),
            ),
          ),
          // 🚀 شريط إدخال الكتابة المعدل (نفس تصميم trainee)
          _inputBar(),
        ],
      ),
    );
  }

  // ============================================================
  // 📝 Input bar مع تحسينات مثل trainee (bottom padding 55)
  // ============================================================
  Widget _inputBar() {
    return Container(
      // إضافة ظل خفيف لتمييز شريط الكتابة
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
          top: 4,
          bottom: 55,  // ✅ المسافة تحت شريط الكتابة (نفس trainee)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focusNode,
                  maxLines: 4,      // السماح بعدة أسطر
                  minLines: 1,      // سطر واحد كحد أدنى
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // زر الإرسال مع خلفية دائرية
            Container(
              margin: const EdgeInsets.only(bottom: 2), // ✅ مسافة إضافية للزر ليتوسط مع حقل الكتابة
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.purple, size: 25),
                onPressed: _send,
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}