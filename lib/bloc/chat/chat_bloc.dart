// ============================================================
// 💬 Chat BLoC - نسخة كاملة محدثة
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/chat_models.dart';
import '../../models/user_model.dart';
import '../../repositories/chat_repository.dart';

// ============================================================
// 💬 Chat BLoC - نسخة كاملة محدثة
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/chat_models.dart';
import '../../models/user_model.dart';
import '../../repositories/chat_repository.dart';

// ============================================================
// 📍 Events
// ============================================================
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// Reset Chat Event
// ============================================================
class ResetChatEvent extends ChatEvent {
  const ResetChatEvent();
}

// ============================================================
// Load Conversations
// ============================================================
class LoadConversationsEvent extends ChatEvent {
  final String userId;
  final UserType userType;

  const LoadConversationsEvent({
    required this.userId,
    required this.userType,
  });

  @override
  List<Object?> get props => [userId, userType];
}

// ============================================================
// Load Messages
// ============================================================
class LoadMessagesEvent extends ChatEvent {
  final String userId;
  final int conversationId;
  final UserType userType;

  const LoadMessagesEvent({
    required this.userId,
    required this.conversationId,
    required this.userType,
  });

  @override
  List<Object?> get props => [userId, conversationId, userType];
}

// ============================================================
// Send Message
// ============================================================
class SendMessageEvent extends ChatEvent {
  final int conversationId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String message;
  final String? courseId;
  final UserType senderType;

  const SendMessageEvent({
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    this.courseId,
    required this.senderType,
  });

  @override
  List<Object?> get props => [
    conversationId,
    senderId,
    receiverId,
    message,
  ];
}

// ============================================================
// Mark Read Event
// ============================================================
class MarkReadEvent extends ChatEvent {
  final String userId;
  final String otherUserId;

  const MarkReadEvent({
    required this.userId,
    required this.otherUserId,
  });

  @override
  List<Object?> get props => [userId, otherUserId];
}

// ============================================================
// States
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

  const ConversationsLoaded({
    required this.conversations,
    this.unreadCount = 0,
  });

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
// Bloc
// ============================================================
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repo;

  List<ChatConversation> _cachedConversations = [];

  ChatBloc({required ChatRepository repo})
      : _repo = repo,
        super(const ChatInitial()) {
    on<LoadConversationsEvent>(_onLoadConvs);
    on<LoadMessagesEvent>(_onLoadMsgs);
    on<SendMessageEvent>(_onSendMsg);
    on<MarkReadEvent>(_onMarkRead);

    on<ResetChatEvent>((event, emit) {
      print("🔄 Reset chat state");
      _cachedConversations = [];
      emit(const ChatInitial());
    });
  }

  // ============================================================
  // Load Conversations
  // ============================================================
  Future<void> _onLoadConvs(
      LoadConversationsEvent event,
      Emitter<ChatState> emit,
      ) async {
    emit(const ChatLoading());

    try {
      final convs = await _repo.loadConversations(
        userId: event.userId,
        userType: event.userType,
      );

      _cachedConversations = convs;

      emit(
        ConversationsLoaded(
          conversations: convs,
          unreadCount: convs.fold(0, (s, c) => s + c.unreadCount),
        ),
      );
    } catch (e) {
      emit(ChatError(message: 'Failed: ${e.toString()}'));
    }
  }

  // ============================================================
  // Load Messages
  // ============================================================
  Future<void> _onLoadMsgs(
      LoadMessagesEvent event,
      Emitter<ChatState> emit,
      ) async {
    emit(const ChatLoading());

    try {
      final msgs = await _repo.loadMessages(
        userId: event.userId,
        conversationId: event.conversationId,
        userType: event.userType,
      );

      emit(MessagesLoaded(messages: msgs));
    } catch (e) {
      emit(ChatError(message: 'Failed: ${e.toString()}'));
    }
  }

  // ============================================================
  // Send Message
  // ============================================================
  Future<void> _onSendMsg(
      SendMessageEvent event,
      Emitter<ChatState> emit,
      ) async {
    try {
      print("📤 START SEND MESSAGE");
      print("🆔 conversationId: ${event.conversationId}");

      bool success = false;

      if (event.senderType == UserType.trainee) {
        success = await _repo.sendMessageAsTrainee(
          conversationId: event.conversationId,
          message: event.message,
        );
      } else {
        success = await _repo.sendMessageAsTrainer(
          conversationId: event.conversationId,
          content: event.message,
        );
      }

      if (success) {
        final msgs = await _repo.loadMessages(
          userId: event.senderId,
          conversationId: event.conversationId,
          userType: event.senderType,
        );

        emit(MessagesLoaded(messages: msgs));
      } else {
        emit(const ChatError(message: 'Failed to send'));
      }
    } catch (e) {
      emit(ChatError(message: 'Error: ${e.toString()}'));
    }
  }

  // ============================================================
  // Mark Read
  // ============================================================
  Future<void> _onMarkRead(
      MarkReadEvent event,
      Emitter<ChatState> emit,
      ) async {
    await _repo.markMessagesAsRead(
      event.userId,
      event.otherUserId,
    );
  }
}