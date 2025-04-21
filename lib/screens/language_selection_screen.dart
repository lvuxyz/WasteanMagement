import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_state.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/language/language_selection_form.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy LanguageBloc hiện có từ context
    final languageBloc = BlocProvider.of<LanguageBloc>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        showBackButton: true,
      ),
      body: BlocProvider.value(
        value: languageBloc, // Sử dụng LanguageBloc hiện có
        child: BlocListener<LanguageBloc, LanguageState>(
          listener: (context, state) {
            if (state is LanguageError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
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

