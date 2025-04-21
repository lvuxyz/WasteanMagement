import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../generated/l10n.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_state.dart';
import '../widgets/language_selector.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final titleText = l10n.languageScreenTitle;
    final languageChangedText = l10n.languageChanged;
    final cancelText = l10n.cancel;
    final saveText = l10n.save;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: BlocListener<LanguageBloc, LanguageState>(
        listener: (context, state) {
          if (state is LanguageLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(languageChangedText)),
            );
          } else if (state is LanguageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LanguageSelector(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(cancelText),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(saveText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 

