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
        title: Row(
          children: [
            Icon(
              Icons.language,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: AssetImage(
                          languageCode == 'vi' 
                              ? 'assets/flags/vn.png' 
                              : 'assets/flags/gb.png'
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    languageCode == 'vi' 
                        ? 'Tiếng Việt' 
                        : 'English',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
} 

