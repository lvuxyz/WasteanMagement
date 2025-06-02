import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wasteanmagement/blocs/chat/chat_event.dart';
import 'package:wasteanmagement/blocs/chat/chat_state.dart';
import 'package:wasteanmagement/models/chat_message.dart';
import 'package:wasteanmagement/services/openai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final OpenAIService _openAIService;
  final Uuid _uuid = const Uuid();
  static const String _chatHistoryKeyPrefix = 'chat_history_user_';
  final String userId;

  ChatBloc({
    required OpenAIService openAIService,
    required this.userId,
  }) : _openAIService = openAIService,
        super(const ChatInitial()) {
    on<ChatInitialized>(_onChatInitialized);
    on<MessageSent>(_onMessageSent);
    on<MessagesLoaded>(_onMessagesLoaded);
    on<MessagesCleared>(_onMessagesCleared);
  }

  String get _chatHistoryKey => '$_chatHistoryKeyPrefix$userId';

  Future<void> _onChatInitialized(
      ChatInitialized event,
      Emitter<ChatState> emit,
      ) async {
    emit(const ChatLoading());
    try {
      final messages = await _loadMessagesFromStorage();

      // Nếu không có tin nhắn cũ, thêm tin nhắn chào mừng từ trợ lý
      if (messages.isEmpty) {
        final welcomeMessage = ChatMessage(
          id: _uuid.v4(),
          content: _openAIService.getWelcomeMessage(),
          role: ChatRole.assistant,
          timestamp: DateTime.now(),
        );
        messages.add(welcomeMessage);
        await _saveMessagesToStorage(messages);
      }

      emit(ChatLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(message: 'Không thể tải lịch sử trò chuyện: $e'));
    }
  }

  Future<void> _onMessageSent(
      MessageSent event,
      Emitter<ChatState> emit,
      ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      // Kiểm tra tin nhắn trùng lặp một cách chính xác
      // Chỉ kiểm tra nếu đang trong trạng thái typing hoặc tin nhắn cuối cùng giống hệt
      if (currentState.isTyping) {
        // Nếu đang typing, bỏ qua tin nhắn này
        return;
      }

      // Kiểm tra trùng lặp với tin nhắn cuối cùng của user
      if (currentState.messages.isNotEmpty) {
        final lastMessage = currentState.messages.last;
        if (lastMessage.role == ChatRole.user &&
            lastMessage.content.trim() == event.message.trim()) {
          // Tin nhắn trùng lặp, bỏ qua
          return;
        }
      }

      // Tạo tin nhắn người dùng mới
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        content: event.message,
        role: ChatRole.user,
        timestamp: DateTime.now(),
      );

      // Cập nhật trạng thái với tin nhắn của người dùng và isTyping = true
      final updatedMessagesWithUser = [...currentState.messages, userMessage];
      emit(currentState.copyWith(
        messages: updatedMessagesWithUser,
        isTyping: true,
      ));

      try {
        // Gọi API OpenAI với lịch sử tin nhắn (không bao gồm tin nhắn vừa thêm)
        final response = await _openAIService.sendMessage(
          message: event.message,
          previousMessages: currentState.messages, // Truyền messages cũ, không bao gồm userMessage vừa thêm
        );

        final assistantMessage = ChatMessage(
          id: _uuid.v4(),
          content: response,
          role: ChatRole.assistant,
          timestamp: DateTime.now(),
        );

        final finalMessages = [...updatedMessagesWithUser, assistantMessage];

        // Lưu tin nhắn vào bộ nhớ cục bộ
        await _saveMessagesToStorage(finalMessages);

        // Cập nhật trạng thái với tin nhắn phản hồi và isTyping = false
        emit(currentState.copyWith(
          messages: finalMessages,
          isTyping: false,
        ));
      } catch (e) {
        // Nếu có lỗi, vẫn giữ tin nhắn user nhưng tắt typing và hiển thị lỗi
        emit(currentState.copyWith(
          messages: updatedMessagesWithUser,
          isTyping: false,
        ));
        emit(ChatError(message: 'Lỗi khi gửi tin nhắn: $e'));
      }
    }
  }

  Future<void> _onMessagesLoaded(
      MessagesLoaded event,
      Emitter<ChatState> emit,
      ) async {
    emit(const ChatLoading());
    try {
      final messages = await _loadMessagesFromStorage();
      emit(ChatLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(message: 'Không thể tải lịch sử trò chuyện: $e'));
    }
  }

  Future<void> _onMessagesCleared(
      MessagesCleared event,
      Emitter<ChatState> emit,
      ) async {
    emit(const ChatLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatHistoryKey);
      emit(const ChatLoaded(messages: []));
    } catch (e) {
      emit(ChatError(message: 'Không thể xóa lịch sử trò chuyện: $e'));
    }
  }

  Future<List<ChatMessage>> _loadMessagesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? chatHistoryJson = prefs.getString(_chatHistoryKey);

      if (chatHistoryJson == null || chatHistoryJson.isEmpty) {
        return [];
      }

      final List<dynamic> chatHistoryList = json.decode(chatHistoryJson);
      return chatHistoryList
          .map((item) => ChatMessage.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveMessagesToStorage(List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistoryJson = json.encode(
        messages.map((message) => message.toJson()).toList(),
      );
      await prefs.setString(_chatHistoryKey, chatHistoryJson);
    } catch (e) {
      // xử lý lỗi nếu cần
    }
  }
}