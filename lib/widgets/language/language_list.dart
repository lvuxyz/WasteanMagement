import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/language_model.dart';
import '../../blocs/language/language_bloc.dart';
import '../../blocs/language/language_event.dart';
import '../../blocs/language/language_state.dart';
import 'language_list_item.dart';

class LanguageList extends StatelessWidget {
  final List<Language> languages;
  final Language selectedLanguage;
  final Function(Language) onLanguageSelected;

  const LanguageList({
    super.key,
    required this.languages,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final noLanguagesFoundText = l10n != null ? l10n.noLanguagesFound : 'No languages found';
    final languageChangeSuccessText = l10n != null ? l10n.languageChangeSuccess : 'Language changed successfully';
    
    return BlocConsumer<LanguageBloc, LanguageState>(
      listener: (context, state) {
        if (state is LanguageLoaded) {
          // Không cần hiển thị thông báo ở đây vì sẽ hiển thị khi nhấn nút Tiếp tục
        }
      },
      builder: (context, state) {
        if (state is LanguageLoaded) {
          final displayLanguages = state.searchQuery.isEmpty 
              ? state.languages 
              : state.filteredLanguages;
          
          if (displayLanguages.isEmpty) {
            return Center(
              child: Text(
                noLanguagesFoundText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }
          
          return ListView.separated(
            itemCount: displayLanguages.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final language = displayLanguages[index];
              // Sử dụng trạng thái hiện tại để xác định ngôn ngữ đã chọn
              final isSelected = state.selectedLanguage.code == language.code;
              
              return LanguageListItem(
                language: language,
                isSelected: isSelected,
                onTap: () {
                  // Khi người dùng chọn một ngôn ngữ
                  onLanguageSelected(language);
                },
              );
            },
          );
        }
        
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
} 