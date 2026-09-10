import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wasteanmagement/models/chat_message.dart';
import '../utils/app_logger.dart';

class OpenAIService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  late final String _apiKey;

  // Giới hạn tin nhắn cho ngữ cảnh - giảm để tăng tốc độ
  static const int _contextMessageLimit = 6;

  // Cache câu trả lời cho các câu hỏi thường gặp
  static final Map<String, String> _quickAnswers = {
    'xin chào': '👋 Chào bạn! Tôi là LVuRác, sẵn sàng hỗ trợ bạn về quản lý chất thải!',
    'hello': '👋 Chào bạn! Tôi là LVuRác, sẵn sàng hỗ trợ bạn về quản lý chất thải!',
    'hi': '👋 Chào bạn! Tôi là LVuRác, sẵn sàng hỗ trợ bạn về quản lý chất thải!',
    'cảm ơn': '😊 Rất vui được giúp đỡ bạn! Có câu hỏi nào khác về quản lý rác thải không?',
    'thank you': '😊 Rất vui được giúp đỡ bạn! Có câu hỏi nào khác về quản lý rác thải không?',
    'thanks': '😊 Rất vui được giúp đỡ bạn! Có câu hỏi nào khác về quản lý rác thải không?',
  };

  OpenAIService() {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      AppLogger.w('OpenAI', 'Thiếu OPENAI_API_KEY trong file .env');
    }

    // Cấu hình timeout để tăng tốc độ
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
    );
  }

  Future<String> sendMessage({required String message, List<ChatMessage>? previousMessages}) async {
    try {
      // Kiểm tra câu trả lời nhanh trước
      final quickAnswer = _getQuickAnswer(message);
      if (quickAnswer != null) {
        // Mô phỏng delay nhỏ để tự nhiên hơn
        await Future.delayed(const Duration(milliseconds: 500));
        return quickAnswer;
      }

      if (_apiKey.isEmpty) {
        return '⚠️ API key chưa được cấu hình. Vui lòng thêm OPENAI_API_KEY vào file .env của bạn.';
      }

      final List<Map<String, String>> messages = [];

      // System message ngắn gọn hơn để giảm token
      messages.add({
        'role': 'system',
        'content': '''
Bạn là LVuRác 🤖, trợ lý AI thân thiện về quản lý chất thải. Hãy:

✅ Trả lời ngắn gọn, dễ hiểu (2-3 câu)
✅ Sử dụng emoji phù hợp
✅ Chỉ trả lời các câu hỏi liên quan đến quản lý chất thải, phân loại rác, tái chế, bảo vệ môi trường và các chủ đề liên quan đến ứng dụng.
✅ Từ chối lịch sự các câu hỏi ngoài chủ đề
✅ Đưa ra lời khuyên thực tế, cụ thể

Ví dụ emoji: ♻️ (tái chế), 🗑️ (rác), 🌍 (môi trường), 💡 (mẹo), ✅ (đúng), ❌ (sai)
'''
      });

      // Giảm ngữ cảnh để tăng tốc độ
      if (previousMessages != null && previousMessages.isNotEmpty) {
        int startIdx = previousMessages.length > _contextMessageLimit
            ? previousMessages.length - _contextMessageLimit
            : 0;

        for (int i = startIdx; i < previousMessages.length; i++) {
          var prevMessage = previousMessages[i];
          messages.add({
            'role': prevMessage.role == ChatRole.user ? 'user' : 'assistant',
            'content': prevMessage.content,
          });
        }
      }

      messages.add({
        'role': 'user',
        'content': message,
      });

      AppLogger.d('OpenAI', 'Gửi ${messages.length} tin nhắn tới OpenAI');

      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
        ),
        data: {
          'model': 'gpt-3.5-turbo', // Thay đổi sang 3.5-turbo để nhanh hơn và rẻ hơn
          'messages': messages,
          'temperature': 0.7, // Giảm để ổn định hơn
          'max_tokens': 400, // Giảm để nhanh hơn
          'presence_penalty': 0.1,
          'frequency_penalty': 0.1,
          'stream': false,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        return content;
      } else {
        return '⚠️ Có lỗi xảy ra khi kết nối với OpenAI. Vui lòng thử lại sau.';
      }
    } catch (e) {
      AppLogger.e('OpenAI', 'Gọi OpenAI API thất bại', error: e);
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return '⏱️ Kết nối chậm, vui lòng thử lại sau.';
        }
      }
      return '❌ Có lỗi xảy ra: ${e.toString().split(':').first}';
    }
  }

  String? _getQuickAnswer(String message) {
    final lowerMessage = message.toLowerCase().trim();

    // Tìm kiếm exact match trước
    if (_quickAnswers.containsKey(lowerMessage)) {
      return _quickAnswers[lowerMessage];
    }

    // Tìm kiếm partial match
    for (var key in _quickAnswers.keys) {
      if (lowerMessage.contains(key)) {
        return _quickAnswers[key];
      }
    }

    return null;
  }

  String getWelcomeMessage() {
    return '👋 Xin chào! Tôi là LVuRác, trợ lý AI về quản lý chất thải.\n\n'
        '🔹 Phân loại rác thải đúng cách\n'
        '🔹 Hướng dẫn tái chế ♻️\n'
        '🔹 Mẹo giảm thiểu rác thải 💡\n'
        '🔹 Bảo vệ môi trường 🌍\n\n'
        '❓ Bạn có câu hỏi gì về quản lý chất thải không?';
  }

  // Thêm method để lấy gợi ý câu hỏi
  List<String> getSuggestedQuestions() {
    return [
      '♻️ Cách phân loại rác tại nhà',
      '🗑️ Rác nào có thể tái chế?',
      '🌍 Làm sao giảm rác thải?',
      '💡 Mẹo xử lý rác hữu cơ',
    ];
  }
}