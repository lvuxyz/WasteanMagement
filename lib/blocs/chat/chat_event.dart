import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  
  @override
  List<Object> get props => [];
}

class ChatInitialized extends ChatEvent {
  const ChatInitialized();
}

class MessageSent extends ChatEvent {
  final String message;
  
  const MessageSent({required this.message});
  
  @override
  List<Object> get props => [message];
}

class MessagesLoaded extends ChatEvent {
  const MessagesLoaded();
}

class MessagesCleared extends ChatEvent {
  const MessagesCleared();
} 