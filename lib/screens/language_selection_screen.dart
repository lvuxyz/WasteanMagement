import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/language/language_bloc.dart';
import '../generated/l10n.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/language/language_selection_form.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.localized(
        context: context,
        titleBuilder: (l10n) => l10n.languageScreenTitle,
      ),
      body: BlocProvider.value(
        value: BlocProvider.of<LanguageBloc>(context),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: LanguageSelectionForm(),
        ),
      ),
    );
  }
} 

