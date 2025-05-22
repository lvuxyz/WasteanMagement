import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:wasteanmagement/blocs/chat/chat_bloc.dart';
import 'package:wasteanmagement/blocs/chat/chat_event.dart';
import 'package:wasteanmagement/blocs/chat/chat_state.dart' as app_states;
import 'package:wasteanmagement/models/chat_message.dart';
import 'package:wasteanmagement/utils/app_colors.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = '/chat';
  
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ChatInitialized());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ lý AI LVuRác'),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showClearChatDialog(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, app_states.ChatState>(
        listener: (context, state) {
          if (state is app_states.ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is app_states.ChatInitial || state is app_states.ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is app_states.ChatLoaded) {
            return Column(
              children: [
                Expanded(
                  child: Chat(
                    messages: _convertMessages(state.messages),
                    onSendPressed: _handleSendPressed,
                    showUserAvatars: true,
                    user: types.User(id: 'user'),
                    theme: DefaultChatTheme(
                      backgroundColor: Colors.white,
                      primaryColor: AppColors.primaryGreen,
                      secondaryColor: Colors.grey[200]!,
                      userAvatarNameColors: [AppColors.primaryGreen],
                    ),
                    emptyState: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hỏi trợ lý AI về quản lý chất thải',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state.isTyping)
                  Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.smart_toy, color: AppColors.primaryGreen),
                        const SizedBox(width: 8),
                        const Text('Đang trả lời...'),
                      ],
                    ),
                  ),
              ],
            );
          }
          
          return const Center(
            child: Text('Có lỗi xảy ra. Vui lòng thử lại sau.'),
          );
        },
      ),
    );
  }

  List<types.Message> _convertMessages(List<ChatMessage> messages) {
    return messages.map((message) {
      return types.TextMessage(
        author: types.User(
          id: message.role == ChatRole.user ? 'user' : 'assistant',
          firstName: message.role == ChatRole.user ? 'Bạn' : 'Trợ lý AI',
        ),
        id: message.id,
        text: message.content,
        createdAt: message.timestamp.millisecondsSinceEpoch,
      );
    }).toList();
  }

  void _handleSendPressed(types.PartialText message) {
    final text = message.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatBloc>().add(MessageSent(message: text));
    }
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử trò chuyện'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả tin nhắn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatBloc>().add(const MessagesCleared());
              Navigator.of(context).pop();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
} 