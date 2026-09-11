import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../blocs/language/language_bloc.dart';
import '../../blocs/language/language_event.dart';
import '../../blocs/language/language_state.dart';
import '../../screens/welcome_screen.dart';
import '../../utils/app_colors.dart';

class LanguageContinueButton extends StatelessWidget {
  const LanguageContinueButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final continueText = l10n.continueButton;
    
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        if (state is LanguageLoaded) {
          return ElevatedButton(
            onPressed: () async {
              // Lưu ngôn ngữ đã chọn
              context.read<LanguageBloc>().add(const LanguageConfirmed());
              
              // Lấy mã ngôn ngữ đã chọn
              final selectedLanguageCode = state.languageCode;
              
              // Widget này là StatelessWidget nên không có `mounted`; giữ
              // sẵn Navigator trước khi vào async gap để không phải tra lại
              // context sau khi màn hình có thể đã bị gỡ.
              final navigator = Navigator.of(context);

              // Chuyển đến màn hình Welcome và đồng thời trả về mã ngôn ngữ
              navigator.pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const WelcomeScreen(),
                ),
              ).then((_) {
                // Khi WelcomeScreen được đóng, trả về mã ngôn ngữ
                navigator.pop(selectedLanguageCode);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              continueText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        
        return ElevatedButton(
          onPressed: null, // Vô hiệu hóa nút khi không có trạng thái hợp lệ
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            continueText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
} 

