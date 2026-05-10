// lib/bloc/chat/chat_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/chat_models.dart';
import '../../repositories/chat_repository.dart';

// ============================================================
// 📍 Events
// ============================================================
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadConversationsEvent extends ChatEvent {
  final String userId;
  const LoadConversationsEvent({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class LoadMessagesEvent extends ChatEvent {
  final String userId;
  final String otherUserId;
  const LoadMessagesEvent({required this.userId, required this.otherUserId});
  @override
  List<Object?> get props => [userId, otherUserId];
}

class SendMessageEvent extends ChatEvent {
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String message;
  final String? imageUrl;
  final String? courseId;
  const SendMessageEvent({
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    this.imageUrl,
    this.courseId,
  });
  @override
  List<Object?> get props => [senderId, receiverId, message];
}

class MarkMessagesAsReadEvent extends ChatEvent {
  final String userId;
  final String otherUserId;
  const MarkMessagesAsReadEvent({required this.userId, required this.otherUserId});
  @override
  List<Object?> get props => [userId, otherUserId];
}

class ClearConversationEvent extends ChatEvent {
  final String userId;
  final String otherUserId;
  const ClearConversationEvent({required this.userId, required this.otherUserId});
  @override
  List<Object?> get props => [userId, otherUserId];
}

// ============================================================
// 📍 States
// ============================================================
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ConversationsLoaded extends ChatState {
  final List<ChatConversation> conversations;
  final int unreadCount;
  const ConversationsLoaded({required this.conversations, this.unreadCount = 0});
  @override
  List<Object?> get props => [conversations, unreadCount];
}

class MessagesLoaded extends ChatState {
  final List<ChatMessage> messages;
  const MessagesLoaded({required this.messages});
  @override
  List<Object?> get props => [messages];
}

class MessageSent extends ChatState {
  final ChatMessage message;
  const MessageSent({required this.message});
  @override
  List<Object?> get props => [message];
}

class ChatError extends ChatState {
  final String message;
  const ChatError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ============================================================
// 🧠 BLoC
// ============================================================
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  // 💾 تخزين مؤقت للمحادثات والرسائل
  List<ChatConversation> _cachedConversations = [];
  List<ChatMessage> _cachedMessages = [];

  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ChatInitial()) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsRead);
    on<ClearConversationEvent>(_onClearConversation);
  }

  // 📍 1. تحميل قائمة المحادثات
  Future<void> _onLoadConversations(
      LoadConversationsEvent event,
      Emitter<ChatState> emit,
      ) async {
    emit(const ChatLoading());

    try {
      final conversations = await _chatRepository.loadConversations(event.userId);
      _cachedConversations = conversations;

      final unreadCount = conversations.fold(0, (sum, conv) => sum + conv.unreadCount);

      emit(ConversationsLoaded(
        conversations: conversations,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(ChatError(message: 'Failed to load conversations: ${e.toString()}'));
    }
  }

  // 📍 2. تحميل رسائل محادثة معينة
  Future<void> _onLoadMessages(
      LoadMessagesEvent event,
      Emitter<ChatState> emit,
      ) async {
    emit(const ChatLoading());

    try {
      final messages = await _chatRepository.loadMessages(event.userId, event.otherUserId);
      _cachedMessages = messages;
      emit(MessagesLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(message: 'Failed to load messages: ${e.toString()}'));
    }
  }

  // 📍 3. إرسال رسالة جديدة
  Future<void> _onSendMessage(
      SendMessageEvent event,
      Emitter<ChatState> emit,
      ) async {
    try {
      final success = await _chatRepository.sendMessage(
        senderId: event.senderId,
        senderName: event.senderName,
        receiverId: event.receiverId,
        receiverName: event.receiverName,
        message: event.message,
        imageUrl: event.imageUrl,
      );

      if (success) {
        // ✅ إنشاء رسالة جديدة
        final newMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: '${event.senderId}_${event.receiverId}',
          senderId: event.senderId,
          senderName: event.senderName,
          receiverId: event.receiverId,
          receiverName: event.receiverName,
          message: event.message,
          timestamp: DateTime.now(),
          isRead: false,
          imageUrl: event.imageUrl,
          courseId: event.courseId,
        );

        // ✅ إضافة إلى القائمة المؤقتة
        _cachedMessages.add(newMessage);

        emit(MessageSent(message: newMessage));
      } else {
        emit(ChatError(message: 'Failed to send message'));
      }
    } catch (e) {
      emit(ChatError(message: 'Error sending message: ${e.toString()}'));
    }
  }

  // 📍 4. تحديث حالة القراءة
  Future<void> _onMarkMessagesAsRead(
      MarkMessagesAsReadEvent event,
      Emitter<ChatState> emit,
      ) async {
    try {
      await _chatRepository.markMessagesAsRead(event.userId, event.otherUserId);
    } catch (e) {
      emit(ChatError(message: 'Failed to mark messages as read: ${e.toString()}'));
    }
  }

  // 📍 5. مسح محادثة
  Future<void> _onClearConversation(
      ClearConversationEvent event,
      Emitter<ChatState> emit,
      ) async {
    try {
      final success = await _chatRepository.clearConversation(event.userId, event.otherUserId);

      if (success) {
        _cachedMessages.clear();
        add(LoadConversationsEvent(userId: event.userId));
      } else {
        emit(ChatError(message: 'Failed to clear conversation'));
      }
    } catch (e) {
      emit(ChatError(message: 'Error clearing conversation: ${e.toString()}'));
    }
  }
}