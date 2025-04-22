import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../generated/l10n.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_state.dart';
import '../utils/language_utils.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final englishText = l10n.english;
    final vietnameseText = l10n.vietnamese;
    final changeLanguageTitle = l10n.changeLanguageTitle;
    final changeLanguageContent = l10n.changeLanguageContent;
    final confirmText = l10n.confirm;
    final cancelText = l10n.cancel;
    final languageChangeSuccessText = l10n.languageChangeSuccess;
    final languageChangeErrorText = l10n.languageChangeError;
    
    return BlocConsumer<LanguageBloc, LanguageState>(
      listener: (context, state) {
        if (state is LanguageError) {
          // Hiển thị thông báo lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is LanguageLoading) {
          // Hiển thị loading indicator khi đang thay đổi ngôn ngữ
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (state is LanguageLoaded) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(
                  context: context,
                  title: englishText,
                  languageCode: 'en',
                  currentLanguageCode: state.languageCode,
                  flagAsset: 'assets/flags/gb.png',
                  changeLanguageTitle: changeLanguageTitle,
                  changeLanguageContent: changeLanguageContent,
                  confirmText: confirmText,
                  cancelText: cancelText,
                  successText: languageChangeSuccessText,
                  errorText: languageChangeErrorText,
                ),
                const Divider(height: 1),
                _buildLanguageOption(
                  context: context,
                  title: vietnameseText,
                  languageCode: 'vi',
                  currentLanguageCode: state.languageCode,
                  flagAsset: 'assets/flags/vn.png',
                  changeLanguageTitle: changeLanguageTitle,
                  changeLanguageContent: changeLanguageContent,
                  confirmText: confirmText,
                  cancelText: cancelText,
                  successText: languageChangeSuccessText,
                  errorText: languageChangeErrorText,
                ),
              ],
            ),
          );
        }
        
        // Fallback khi không có trạng thái nào phù hợp
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
  
  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required String languageCode,
    required String currentLanguageCode,
    required String flagAsset,
    required String changeLanguageTitle,
    required String changeLanguageContent,
    required String confirmText,
    required String cancelText,
    required String successText,
    required String errorText,
  }) {
    final isSelected = languageCode == currentLanguageCode;
    
    return InkWell(
      onTap: () async {
        if (!isSelected) {
          // Hiển thị hộp thoại xác nhận thay đổi ngôn ngữ
          final shouldChange = await LanguageUtils.showLanguageConfirmationDialog(
            context,
            languageCode,
            changeLanguageTitle,
            changeLanguageContent,
            confirmText,
            cancelText,
          );
          
          if (shouldChange && context.mounted) {
            // Sử dụng tiện ích để thay đổi ngôn ngữ
            final success = await LanguageUtils.changeLanguage(context, languageCode);
            
            if (context.mounted) {
              // Hiển thị thông báo thành công hoặc lỗi
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? successText : errorText),
                  backgroundColor: success ? Colors.green : Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Hiển thị cờ quốc gia
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                flagAsset,
                width: 24,
                height: 16,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.language, size: 24);
                },
              ),
            ),
            const SizedBox(width: 16),
            // Tên ngôn ngữ
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            // Biểu tượng đã chọn
            if (isSelected)
              const Icon(Icons.check, color: Colors.green)
          ],
        ),
      ),
    );
  }
} 

