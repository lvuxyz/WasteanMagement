import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../blocs/language/language_bloc.dart';
import '../../blocs/language/language_event.dart';
import '../../screens/welcome_screen.dart';
import '../../utils/app_colors.dart';

class LanguageContinueButton extends StatelessWidget {
  const LanguageContinueButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final continueText = l10n != null ? l10n.continueButton : 'Continue';
    
    return ElevatedButton(
      onPressed: () {
        context.read<LanguageBloc>().add(const LanguageConfirmed());
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              final languageBloc = BlocProvider.of<LanguageBloc>(context);
              
              return BlocProvider.value(
                value: languageBloc,
                child: const WelcomeScreen(),
              );
            },
          ),
        );
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
} 