import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_state.dart';
import '../generated/l10n.dart';
import '../services/language_service.dart';
import '../utils/app_colors.dart';

class LanguageQuickSwitcher extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? iconSize;
  final bool showText;
  final bool useDropdown;

  const LanguageQuickSwitcher({
    Key? key,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.iconSize,
    this.showText = true,
    this.useDropdown = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        if (state is LanguageLoaded) {
          final l10n = S.of(context);
          final isEnglish = state.languageCode == 'en';
          final currentLanguage = isEnglish ? l10n.english : l10n.vietnamese;
          
          if (useDropdown) {
            return _buildDropdown(context, l10n, state.languageCode);
          } else {
            return InkWell(
              onTap: () => _handleLanguageChange(context, state.languageCode),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language,
                      size: iconSize ?? 20,
                      color: iconColor ?? AppColors.primaryGreen,
                    ),
                    if (showText) ... [
                      const SizedBox(width: 4),
                      Text(
                        currentLanguage,
                        style: TextStyle(
                          color: textColor ?? AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
  
  Widget _buildDropdown(BuildContext context, S l10n, String currentLanguageCode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLanguageCode,
          icon: Icon(
            Icons.arrow_drop_down,
            color: iconColor ?? AppColors.primaryGreen,
          ),
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    size: iconSize ?? 16,
                    color: iconColor ?? AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.english,
                    style: TextStyle(
                      color: textColor ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'vi',
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    size: iconSize ?? 16,
                    color: iconColor ?? AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.vietnamese,
                    style: TextStyle(
                      color: textColor ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null && value != currentLanguageCode) {
              _handleLanguageChange(context, currentLanguageCode);
            }
          },
        ),
      ),
    );
  }
  
  Future<void> _handleLanguageChange(BuildContext context, String currentLanguageCode) async {
    final l10n = S.of(context);
    final newLanguageCode = currentLanguageCode == 'en' ? 'vi' : 'en';
    
    final confirmed = await LanguageService.showLanguageConfirmationDialog(
      context,
      newLanguageCode,
      title: l10n.changeLanguageTitle,
      content: l10n.changeLanguageContent,
      confirmText: l10n.confirm,
      cancelText: l10n.cancel,
    );
    
    if (confirmed) {
      await LanguageService.changeLanguage(context, newLanguageCode);
    }
  }
} 