import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/language/language_bloc.dart';
import '../../blocs/language/language_event.dart';
import '../../blocs/language/language_state.dart';
import '../../utils/app_colors.dart';
import 'language_list.dart';
import 'language_search_field.dart';
import 'language_continue_button.dart';

class LanguageSelectionForm extends StatelessWidget {
  const LanguageSelectionForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        if (state is LanguageLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is LanguageLoaded) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn ngôn ngữ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Đừng lo lắng! Điều đó xảy ra. Vui lòng nhập email được liên kết với tài khoản của bạn.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Search field
                const LanguageSearchField(),
                const SizedBox(height: 16),
                
                // Language list
                Expanded(
                  child: LanguageList(
                    languages: state.languages,
                    selectedLanguage: state.selectedLanguage,
                    onLanguageSelected: (language) {
                      context.read<LanguageBloc>().add(LanguageSelected(language: language));
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Continue button
                const LanguageContinueButton(),
              ],
            ),
          );
        }
        
        return const Center(child: Text('Failed to load languages'));
      },
    );
  }
} 