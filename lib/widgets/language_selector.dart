import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_event.dart';
import '../blocs/language/language_state.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final englishText = l10n != null ? l10n.english : 'English';
    final vietnameseText = l10n != null ? l10n.vietnamese : 'Vietnamese';
    
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        if (state is LanguageLoaded) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(englishText),
                value: 'en',
                groupValue: state.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<LanguageBloc>().add(ChangeLanguage(value));
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(vietnameseText),
                value: 'vi',
                groupValue: state.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<LanguageBloc>().add(ChangeLanguage(value));
                  }
                },
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
} 