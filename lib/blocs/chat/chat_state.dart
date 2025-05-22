import 'package:equatable/equatable.dart';
import 'package:wasteanmagement/models/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  
  const ChatLoaded({
    required this.messages,
    this.isTyping = false,
  });
  
  @override
  List<Object> get props => [messages, isTyping];
  
  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  
  const ChatError({required this.message});
  
  @override
  List<Object> get props => [message];
} 