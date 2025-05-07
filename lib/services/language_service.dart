import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_state.dart';
import '../generated/l10n.dart';
import '../utils/language_utils.dart';

/// A service class to handle language-related operations throughout the app
class LanguageService {
  /// Gets the current language code from context
  static String getCurrentLanguageCode(BuildContext context) {
    return LanguageUtils.getCurrentLanguageCode(context);
  }
  
  /// Determines if the current language matches the provided code
  static bool isCurrentLanguage(BuildContext context, String languageCode) {
    return LanguageUtils.isCurrentLanguage(context, languageCode);
  }
  
  /// Changes the application language
  static Future<bool> changeLanguage(BuildContext context, String languageCode) async {
    return LanguageUtils.changeLanguage(context, languageCode);
  }
  
  /// Shows a confirmation dialog before changing the language
  static Future<bool> showLanguageConfirmationDialog(
    BuildContext context, 
    String languageCode,
    {String? title, String? content, String? confirmText, String? cancelText}
  ) async {
    final l10n = S.of(context);
    
    return LanguageUtils.showLanguageConfirmationDialog(
      context,
      languageCode,
      title ?? l10n.changeLanguageTitle,
      content ?? l10n.changeLanguageContent,
      confirmText ?? l10n.confirm,
      cancelText ?? l10n.cancel,
    );
  }
  
  /// Adds a Language widget to any screen that needs language support
  static Widget withLanguageSupport({
    required Widget child,
    Function(BuildContext, LanguageState)? listener,
  }) {
    return BlocListener<LanguageBloc, LanguageState>(
      listener: (context, state) {
        if (listener != null) {
          listener(context, state);
        }
        
        if (state is LanguageError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: child,
    );
  }
  
  /// Creates a language selector with custom styling
  static Widget buildLanguageSelector({
    required BuildContext context,
    Widget? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final l10n = S.of(context);
    
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        if (state is LanguageLoaded) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon ?? const Icon(Icons.language, size: 20),
                const SizedBox(width: 4),
                Text(
                  state.languageCode == 'en' ? l10n.english : l10n.vietnamese,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
} 