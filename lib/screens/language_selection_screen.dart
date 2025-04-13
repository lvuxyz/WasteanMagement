import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/blocs/language/language_repository.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_event.dart';
import '../blocs/language/language_state.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/language/language_selection_form.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LanguageBloc(repository: LanguageRepository())..add(LanguageInitialized()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(
          showBackButton: false,
        ),
        body: BlocListener<LanguageBloc, LanguageState>(
          listener: (context, state) {
            if (state is LanguageError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: const LanguageSelectionForm(),
        ),
      ),
    );
  }
} 