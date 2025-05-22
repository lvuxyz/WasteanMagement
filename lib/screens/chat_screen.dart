import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/blocs/chat/chat_bloc.dart';
import 'package:wasteanmagement/blocs/chat/chat_event.dart';
import 'package:wasteanmagement/blocs/chat/chat_state.dart' as app_states;
import 'package:wasteanmagement/models/chat_message.dart';
import 'package:wasteanmagement/utils/app_colors.dart';
import 'package:wasteanmagement/services/openai_service.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = '/chat';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;
  bool _isDisposed = false;
  bool _isNavigating = false;

  bool get canUseFocus => !_isDisposed && !_isNavigating && mounted && _focusNode.canRequestFocus;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ChatInitialized());

    // Khởi tạo animation cho typing indicator
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Cancel pending operations that might access focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will execute after current frame is complete, canceling any ongoing unfocus operations
    });
    
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  // Safe way to unfocus that won't cause errors
  void _safeUnfocus() {
    if (canUseFocus) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _isNavigating = true;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.primaryGreen,
                  radius: 18,
                  child: const Text(
                    '🤖',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LVuRác AI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Trợ lý quản lý chất thải',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primaryGreen.withOpacity(0.3),
          leadingWidth: 30,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            padding: EdgeInsets.zero,
            onPressed: () {
              _isNavigating = true;
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_outlined, size: 22),
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
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            // Điều khiển animation khi typing
            if (state is app_states.ChatLoaded) {
              if (state.isTyping) {
                _typingAnimationController.repeat(reverse: true);
              } else {
                _typingAnimationController.stop();
              }
            }

            // Scroll to bottom khi có tin nhắn mới
            if (state is app_states.ChatLoaded && state.messages.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 100), () {
                _safeScrollToBottom();
              });
            }
          },
          builder: (context, state) {
            if (state is app_states.ChatInitial || state is app_states.ChatLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text('🤖', style: TextStyle(fontSize: 40)),
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      'Đang khởi tạo LVuRác...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is app_states.ChatLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: state.messages.isEmpty
                        ? _buildEmptyStateWithSuggestions()
                        : _buildChatMessages(state.messages),
                  ),
                  if (state.isTyping) _buildImprovedTypingIndicator(),
                  _buildMessageInput(),
                ],
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Có lỗi xảy ra'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ChatBloc>().add(const ChatInitialized());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyStateWithSuggestions() {
    final suggestions = OpenAIService().getSuggestedQuestions();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.primaryGreen.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text('🤖', style: TextStyle(fontSize: 60)),
          ),
          const SizedBox(height: 24),
          Text(
            'Chào bạn! Tôi là LVuRác 👋',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Trợ lý thông minh về quản lý chất thải',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Gợi ý câu hỏi:',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) =>
                _buildSuggestionChip(suggestion)
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return InkWell(
      onTap: () => _sendMessage(suggestion),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          suggestion,
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildImprovedTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🤖', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _typingAnimation,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200 + (index * 100)),
                            width: 6,
                            height: 6 + (_typingAnimation.value * 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(
                                  0.3 + (_typingAnimation.value * 0.7)
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Đang soạn...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUserMessage = message.role == ChatRole.user;
        final showDate = index == 0 ||
            !_isSameDay(messages[index].timestamp, messages[index - 1].timestamp);

        return Column(
          children: [
            if (showDate) _buildDateDivider(message.timestamp),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _EnhancedMessageBubble(
                message: message.content,
                isUser: isUserMessage,
                time: _formatTime(message.timestamp),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _formatDate(date),
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Hôm nay';
    } else if (messageDate == yesterday) {
      return 'Hôm qua';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Nhập câu hỏi về quản lý rác thải...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: _sendMessage,
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryGreen.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => _sendMessage(_textController.text),
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isNotEmpty && !_isDisposed && mounted) {
      _safeUnfocus();
      context.read<ChatBloc>().add(MessageSent(message: trimmedText));
      _textController.clear();
    }
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.orange),
            SizedBox(width: 8),
            Text('Làm mới trò chuyện'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả tin nhắn và bắt đầu lại? Lịch sử trò chuyện của bạn sẽ được xóa khỏi thiết bị này.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ChatBloc>().add(const MessagesCleared());
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Làm mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Add this safety method to check if it's safe to scroll
  void _safeScrollToBottom() {
    if (_isDisposed || !mounted || !_scrollController.hasClients) return;
    
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
}

class _EnhancedMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String time;

  const _EnhancedMessageBubble({
    required this.message,
    required this.isUser,
    required this.time,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Avatar và tên
        if (!isUser)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🤖', style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 6),
                Text(
                  'LVuRác',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Bạn',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('👤', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

        // Tin nhắn chính
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Container(
              margin: EdgeInsets.only(
                left: isUser ? 0 : 8,
                right: isUser ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser ? LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.primaryGreen.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ) : null,
                color: isUser ? null : Colors.grey[100],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isUser ? Colors.white.withOpacity(0.8) : Colors.black45,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}