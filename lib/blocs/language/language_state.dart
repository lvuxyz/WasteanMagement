import '../../models/language_model.dart';
import 'package:equatable/equatable.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();
  
  @override
  List<Object> get props => [];
}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguageLoaded extends LanguageState {
  final String languageCode;
  final List<Language> languages;
  final Language selectedLanguage;
  final List<Language> filteredLanguages;
  final String searchQuery;
  
  const LanguageLoaded({
    required this.languageCode,
    required this.languages,
    required this.selectedLanguage,
    this.filteredLanguages = const [],
    this.searchQuery = '',
  });
  
  @override
  List<Object> get props => [languageCode, languages, selectedLanguage, filteredLanguages, searchQuery];
  
  LanguageLoaded copyWith({
    String? languageCode,
    List<Language>? languages,
    Language? selectedLanguage,
    List<Language>? filteredLanguages,
    String? searchQuery,
  }) {
    return LanguageLoaded(
      languageCode: languageCode ?? this.languageCode,
      languages: languages ?? this.languages,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      filteredLanguages: filteredLanguages ?? this.filteredLanguages,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class LanguageError extends LanguageState {
  final String message;
  final String error;
  
  const LanguageError(this.message, {this.error = ''});
  
  @override
  List<Object> get props => [message, error];
} 