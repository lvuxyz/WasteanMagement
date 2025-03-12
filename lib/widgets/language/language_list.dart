import 'package:flutter/material.dart';
import '../../models/language_model.dart';
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
    return ListView.separated(
      itemCount: languages.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final language = languages[index];
        final isSelected = selectedLanguage.code == language.code;
        
        return LanguageListItem(
          language: language,
          isSelected: isSelected,
          onTap: () => onLanguageSelected(language),
        );
      },
    );
  }
} 