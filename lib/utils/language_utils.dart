import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_event.dart';
import '../blocs/language/language_state.dart';

/// Lớp tiện ích để hỗ trợ việc chuyển đổi ngôn ngữ
class LanguageUtils {
  /// Chuyển đổi ngôn ngữ và đảm bảo ứng dụng được rebuild
  static Future<bool> changeLanguage(BuildContext context, String languageCode) async {
    final completer = Completer<bool>();
    
    // Lấy bloc từ context
    final languageBloc = BlocProvider.of<LanguageBloc>(context);
    
    // Lắng nghe sự thay đổi trạng thái
    final subscription = languageBloc.stream.listen((state) {
      if (state is LanguageLoaded && state.languageCode == languageCode) {
        // Ngôn ngữ đã được thay đổi thành công
        completer.complete(true);
      } else if (state is LanguageError) {
        // Có lỗi khi thay đổi ngôn ngữ
        completer.complete(false);
      }
    });
    
    // Gửi sự kiện thay đổi ngôn ngữ
    languageBloc.add(ChangeLanguage(languageCode));
    
    // Đợi kết quả hoặc timeout sau 5 giây
    final result = await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => false,
    );
    
    // Hủy đăng ký lắng nghe
    subscription.cancel();
    
    return result;
  }
  
  /// Kiểm tra xem ngôn ngữ hiện tại có phải là ngôn ngữ được chỉ định không
  static bool isCurrentLanguage(BuildContext context, String languageCode) {
    final state = context.read<LanguageBloc>().state;
    if (state is LanguageLoaded) {
      return state.languageCode == languageCode;
    }
    return false;
  }
  
  /// Lấy mã ngôn ngữ hiện tại
  static String getCurrentLanguageCode(BuildContext context) {
    final state = context.read<LanguageBloc>().state;
    if (state is LanguageLoaded) {
      return state.languageCode;
    }
    return 'en'; // Mặc định là tiếng Anh
  }
  
  /// Hiển thị hộp thoại xác nhận thay đổi ngôn ngữ
  static Future<bool> showLanguageConfirmationDialog(
    BuildContext context,
    String languageCode,
    String title,
    String content,
    String confirmText,
    String cancelText,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
} 

