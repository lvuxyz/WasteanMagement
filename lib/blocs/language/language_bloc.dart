import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/language_model.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(LanguageInitial()) {
    on<LanguageInitialized>(_onLanguageInitialized);
    on<LanguageSelected>(_onLanguageSelected);
    on<LanguageConfirmed>(_onLanguageConfirmed);
  }

  Future<void> _onLanguageInitialized(
    LanguageInitialized event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());

    try {
      // In a real app, this would be loaded from a local storage or API
      final languages = [
        Language(
          code: 'en',
          name: 'English',
          flagAsset: 'assets/flags/gb.png',
          isSelected: false,
        ),
        Language(
          code: 'vi',
          name: 'Tiếng Việt',
          flagAsset: 'assets/flags/vn.png',
          isSelected: true,
        ),
      ];

      // Default to Vietnamese
      final selectedLanguage = languages.firstWhere((lang) => lang.isSelected);

      emit(LanguageLoaded(
        languages: languages,
        selectedLanguage: selectedLanguage,
      ));
    } catch (e) {
      emit(LanguageError(error: 'Failed to load languages: $e'));
    }
  }

  void _onLanguageSelected(
    LanguageSelected event,
    Emitter<LanguageState> emit,
  ) {
    if (state is LanguageLoaded) {
      final currentState = state as LanguageLoaded;
      final updatedLanguages = currentState.languages.map((language) {
        return language.copyWith(
          isSelected: language.code == event.language.code,
        );
      }).toList();

      emit(currentState.copyWith(
        languages: updatedLanguages,
        selectedLanguage: event.language,
      ));
    }
  }

  void _onLanguageConfirmed(
    LanguageConfirmed event,
    Emitter<LanguageState> emit,
  ) {
    // In a real app, this would save the selected language to local storage
    // and update the app's locale
    if (state is LanguageLoaded) {
      // No state change needed, the navigation will be handled in the UI
    }
  }
} 