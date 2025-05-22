import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wasteanmagement/models/chat_message.dart';

class OpenAIService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  late final String _apiKey;
  
  // Giới hạn số lượng tin nhắn được gửi trong mỗi yêu cầu để giữ ngữ cảnh
  // Giảm số này nếu token quá lớn, tăng nếu cần nhiều ngữ cảnh hơn
  static const int _contextMessageLimit = 10;

  OpenAIService() {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      debugPrint('OPENAI_API_KEY không được cấu hình trong file .env');
    }
  }

  Future<String> sendMessage({required String message, List<ChatMessage>? previousMessages}) async {
    try {
      if (_apiKey.isEmpty) {
        return 'API key chưa được cấu hình. Vui lòng thêm OPENAI_API_KEY vào file .env của bạn.';
      }

      // Chuẩn bị danh sách tin nhắn để gửi đến API
      final List<Map<String, String>> messages = [];
      
      // Luôn thêm thông điệp hệ thống đầu tiên
      messages.add({
        'role': 'system',
        'content': 'Bạn là trợ lý AI trong ứng dụng quản lý chất thải LVuRác. Bạn chỉ trả lời các câu hỏi liên quan đến quản lý chất thải, phân loại rác, tái chế, bảo vệ môi trường, và các chủ đề liên quan đến ứng dụng. Với các câu hỏi không liên quan, hãy lịch sự từ chối và gợi ý người dùng hỏi về các chủ đề liên quan đến quản lý chất thải.'
      });
      
      // Thêm tin nhắn trước đó để duy trì ngữ cảnh
      if (previousMessages != null && previousMessages.isNotEmpty) {
        // Lấy các tin nhắn gần nhất trong giới hạn
        final contextMessages = previousMessages.length <= _contextMessageLimit 
          ? previousMessages 
          : previousMessages.sublist(previousMessages.length - _contextMessageLimit);
          
        for (var prevMessage in contextMessages) {
          messages.add({
            'role': prevMessage.role == ChatRole.user ? 'user' : 'assistant',
            'content': prevMessage.content,
          });
        }
      }
      
      // Thêm tin nhắn hiện tại
      messages.add({
        'role': 'user',
        'content': message,
      });

      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        return content;
      } else {
        return 'Có lỗi xảy ra khi kết nối với OpenAI. Vui lòng thử lại sau.';
      }
    } catch (e) {
      debugPrint('Lỗi khi gọi OpenAI API: $e');
      return 'Có lỗi xảy ra: $e';
    }
  }
} 