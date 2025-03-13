import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../blocs/language/language_bloc.dart';
import '../../blocs/language/language_event.dart';
import '../../blocs/language/language_state.dart';
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
          final l10n = AppLocalizations.of(context);
          final title = l10n != null ? l10n.languageScreenTitle : 'Select Language';
          final subtitle = 'Choose your preferred language for the application';
          
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: const TextStyle(
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
                    languages: state.filteredLanguages.isEmpty && state.searchQuery.isEmpty
                        ? state.languages
                        : state.filteredLanguages,
                    selectedLanguage: state.selectedLanguage,
                    onLanguageSelected: (language) {
                      context.read<LanguageBloc>().add(ChangeLanguage(language.code));
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