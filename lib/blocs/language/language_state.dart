import '../../models/language_model.dart';

abstract class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguageLoaded extends LanguageState {
  final List<Language> languages;
  final Language selectedLanguage;

  LanguageLoaded({
    required this.languages,
    required this.selectedLanguage,
  });

  LanguageLoaded copyWith({
    List<Language>? languages,
    Language? selectedLanguage,
  }) {
    return LanguageLoaded(
      languages: languages ?? this.languages,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

class LanguageError extends LanguageState {
  final String error;

  LanguageError({required this.error});
} 