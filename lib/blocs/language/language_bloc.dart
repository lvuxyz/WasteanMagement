import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/language_model.dart';
import 'language_event.dart';
import 'language_state.dart';
import 'language_repository.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final LanguageRepository repository;
  
  // Danh sách ngôn ngữ mặc định
  final List<Language> _supportedLanguages = [
    Language(
      code: 'en',
      name: 'English',
      flagAsset: 'assets/flags/gb.png',
    ),
    Language(
      code: 'vi',
      name: 'Tiếng Việt',
      flagAsset: 'assets/flags/vn.png',
    ),
  ];
  
  LanguageBloc({required this.repository}) : super(LanguageInitial()) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
    on<LanguageInitialized>(_onLanguageInitialized);
    on<LanguageSelected>(_onLanguageSelected);
    on<LanguageConfirmed>(_onLanguageConfirmed);
    on<SearchLanguage>(_onSearchLanguage);
  }
  
  Future<void> _onLoadLanguage(
    LoadLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());
    try {
      final String languageCode = await repository.getLanguageCode();
      final selectedLanguage = _supportedLanguages.firstWhere(
        (lang) => lang.code == languageCode,
        orElse: () => _supportedLanguages.first,
      );
      
      emit(LanguageLoaded(
        languageCode: languageCode,
        languages: _supportedLanguages,
        selectedLanguage: selectedLanguage,
        filteredLanguages: _supportedLanguages,
      ));
    } catch (e) {
      emit(LanguageError('Failed to load language preference'));
    }
  }
  
  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    if (state is LanguageLoaded) {
      final currentState = state as LanguageLoaded;
      emit(LanguageLoading());
      try {
        await repository.setLanguageCode(event.languageCode);
        final selectedLanguage = _supportedLanguages.firstWhere(
          (lang) => lang.code == event.languageCode,
          orElse: () => _supportedLanguages.first,
        );
        
        emit(currentState.copyWith(
          languageCode: event.languageCode,
          selectedLanguage: selectedLanguage,
        ));
      } catch (e) {
        emit(LanguageError('Failed to change language'));
      }
    }
  }
  
  void _onLanguageInitialized(
    LanguageInitialized event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());
    try {
      final String languageCode = await repository.getLanguageCode();
      final selectedLanguage = _supportedLanguages.firstWhere(
        (lang) => lang.code == languageCode,
        orElse: () => _supportedLanguages.first,
      );
      
      emit(LanguageLoaded(
        languageCode: languageCode,
        languages: _supportedLanguages,
        selectedLanguage: selectedLanguage,
        filteredLanguages: _supportedLanguages,
      ));
    } catch (e) {
      emit(LanguageError('Failed to initialize language'));
    }
  }
  
  void _onLanguageSelected(
    LanguageSelected event,
    Emitter<LanguageState> emit,
  ) {
    if (state is LanguageLoaded) {
      final currentState = state as LanguageLoaded;
      emit(currentState.copyWith(
        selectedLanguage: event.language,
        languageCode: event.language.code,
      ));
    }
  }
  
  Future<void> _onLanguageConfirmed(
    LanguageConfirmed event,
    Emitter<LanguageState> emit,
  ) async {
    if (state is LanguageLoaded) {
      final currentState = state as LanguageLoaded;
      try {
        await repository.setLanguageCode(currentState.selectedLanguage.code);
      } catch (e) {
        emit(LanguageError('Failed to save language preference'));
      }
    }
  }
  
  void _onSearchLanguage(
    SearchLanguage event,
    Emitter<LanguageState> emit,
  ) {
    if (state is LanguageLoaded) {
      final currentState = state as LanguageLoaded;
      final query = event.query.toLowerCase();
      
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredLanguages: currentState.languages,
          searchQuery: query,
        ));
      } else {
        final filteredLanguages = currentState.languages
            .where((language) => 
                language.name.toLowerCase().contains(query) ||
                language.code.toLowerCase().contains(query))
            .toList();
        
        emit(currentState.copyWith(
          filteredLanguages: filteredLanguages,
          searchQuery: query,
        ));
      }
    }
  }
} 