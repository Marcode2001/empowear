// trainee_chat_page.dart
// ============================================================
// 📱 TRAINEE CHAT PAGE - With Message Bubbles (Left/Right + Gradient)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../models/chat_models.dart';
import '../../models/user_model.dart';

// ============================================================
// 📋 CONVERSATIONS LIST - Trainee Side
// ============================================================

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({super.key});

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  // Flag to prevent duplicate loading
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // Load conversations after first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthBloc>().state;

      if (auth is AuthAuthenticated) {
        context.read<ChatBloc>().add(
          LoadConversationsEvent(
            userId: auth.user.id,
            userType: UserType.trainee,
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
                print("🆔 conversation id = ${conv.id}");
                print("📦 RAW CONVERSATION:");
                print("👩‍🏫 trainerFullName = ${conv.trainerFullName}");
                print("👨‍🎓 traineeFullName = ${conv.traineeFullName}");
                final name = conv.getPartnerName(UserType.trainee);
                final partnerId = conv.getPartnerId(UserType.trainee);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        builder: (_) => ChatDetailPage(
                          conversationId: conv.id,
                          partnerName: name,
                          partnerId: partnerId,
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
                          userType: UserType.trainee,
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
          return const Center(
            child: Text('No data available', style: TextStyle(color: Colors.grey)),
          );
        },
      ),
    );
  }
}

// ============================================================
// 💬 CHAT DETAIL PAGE - With Message Bubbles (Right/Left + Gradient)
// ============================================================

class ChatDetailPage extends StatefulWidget {
  final int conversationId;
  final String partnerName;
  final String partnerId;
  final String? courseName;
  final int relatedCourse;
  final String storageKey;

  const ChatDetailPage({
    super.key,
    required this.conversationId,
    required this.partnerName,
    required this.partnerId,
    this.courseName,
    required this.relatedCourse,
    required this.storageKey,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<ChatMessage> _msgs = [];
  bool _loaded = false;

  // Focus node للتحكم بحقل الكتابة والإظهار فوق لوحة المفاتيح
  final FocusNode _focusNode = FocusNode();

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
          userType: UserType.trainee,
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
          receiverId: widget.partnerId,
          receiverName: widget.partnerName,
          message: _ctrl.text.trim(),
          courseId: widget.relatedCourse.toString(),
          senderType: UserType.trainee,
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

  // Check if message is from current user
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
          // 🎨 الحفاظ على لون البابل الأصلي كما هو بدون تغيير
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
        // 🎨 جعل اسم الشخص الذي تتم محادثته باللون الأبيض
        title: Text(
          widget.partnerName,
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
        iconTheme: const IconThemeData(color: Colors.white),
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
          // 🚀 شريط إدخال الكتابة المعدل
          _inputBar(),
        ],
      ),
    );
  }

  // ============================================================
// 📝 Input bar مع تحسينات لظهوره فوق لوحة المفاتيح
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
          bottom: 55,  //  المسافة  تحت شريط الكتابة
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