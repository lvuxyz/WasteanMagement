import '../../models/language_model.dart';
import 'package:equatable/equatable.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();
  
  @override
  List<Object> get props => [];
}

class LoadLanguage extends LanguageEvent {
  const LoadLanguage();
}

class ChangeLanguage extends LanguageEvent {
  final String languageCode;
  
  const ChangeLanguage(this.languageCode);
  
  @override
  List<Object> get props => [languageCode];
}

class LanguageInitialized extends LanguageEvent {
  const LanguageInitialized();
}

class LanguageSelected extends LanguageEvent {
  final Language language;

  const LanguageSelected({required this.language});

  @override
  List<Object> get props => [language];
}

class LanguageConfirmed extends LanguageEvent {
  const LanguageConfirmed();
}

class SearchLanguage extends LanguageEvent {
  final String query;
  
  const SearchLanguage(this.query);
  
  @override
  List<Object> get props => [query];
} 