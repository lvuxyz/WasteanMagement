import '../../models/language_model.dart';

abstract class LanguageEvent {}

class LanguageInitialized extends LanguageEvent {}

class LanguageSelected extends LanguageEvent {
  final Language language;

  LanguageSelected({required this.language});
}

class LanguageConfirmed extends LanguageEvent {} 