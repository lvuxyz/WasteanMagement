import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  late final String _apiKey;

  OpenAIService() {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      debugPrint('OPENAI_API_KEY không được cấu hình trong file .env');
    }
  }

  Future<String> sendMessage({required String message}) async {
    try {
      if (_apiKey.isEmpty) {
        return 'API key chưa được cấu hình. Vui lòng thêm OPENAI_API_KEY vào file .env của bạn.';
      }

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
          'messages': [
            {
              'role': 'system',
              'content': 'Bạn là trợ lý AI trong ứng dụng quản lý chất thải LVuRác. Bạn chỉ trả lời các câu hỏi liên quan đến quản lý chất thải, phân loại rác, tái chế, bảo vệ môi trường, và các chủ đề liên quan đến ứng dụng. Với các câu hỏi không liên quan, hãy lịch sự từ chối và gợi ý người dùng hỏi về các chủ đề liên quan đến quản lý chất thải.'
            },
            {
              'role': 'user',
              'content': message,
            }
          ],
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