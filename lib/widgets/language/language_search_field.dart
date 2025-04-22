import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../generated/l10n.dart';
import '../../blocs/language/language_bloc.dart';
import '../../blocs/language/language_event.dart';
import '../../blocs/language/language_state.dart';

class LanguageSearchField extends StatelessWidget {
  const LanguageSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final hintText = l10n.searchLanguage;
    
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String searchQuery = '';
        
        if (state is LanguageLoaded) {
          searchQuery = state.searchQuery;
        }
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        context.read<LanguageBloc>().add(const SearchLanguage(''));
                      },
                    )
                  : null,
            ),
            style: const TextStyle(fontSize: 16),
            onChanged: (value) {
              context.read<LanguageBloc>().add(SearchLanguage(value));
            },
          ),
        );
      },
    );
  }
} 

