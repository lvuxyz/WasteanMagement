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
      // Thêm độ trễ nhỏ để đảm bảo UI hiển thị loading indicator
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Lấy mã ngôn ngữ đã lưu
      final String languageCode = await repository.getLanguageCode();
      
      // Tìm đối tượng ngôn ngữ tương ứng
      final selectedLanguage = _supportedLanguages.firstWhere(
        (lang) => lang.code == languageCode,
        orElse: () => _supportedLanguages.first,
      );
      
      // Cập nhật trạng thái với ngôn ngữ đã tải
      emit(LanguageLoaded(
        languageCode: languageCode,
        languages: _supportedLanguages,
        selectedLanguage: selectedLanguage,
        filteredLanguages: _supportedLanguages,
      ));
    } catch (e) {
      // Xử lý lỗi và cung cấp thông tin chi tiết hơn
      emit(LanguageError(
        'Failed to load language preference',
        error: e.toString(),
      ));
      
      // Sau một khoảng thời gian, thử tải lại với ngôn ngữ mặc định
      Future.delayed(const Duration(seconds: 2), () {
        final defaultLanguage = _supportedLanguages.first;
        emit(LanguageLoaded(
          languageCode: defaultLanguage.code,
          languages: _supportedLanguages,
          selectedLanguage: defaultLanguage,
          filteredLanguages: _supportedLanguages,
        ));
      });
    }
  }
  
  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    if (state is LanguageLoaded) {
      final currentState = state as LanguageLoaded;
      
      // Kiểm tra xem ngôn ngữ đã được chọn chưa để tránh thay đổi không cần thiết
      if (currentState.languageCode == event.languageCode) {
        return; // Không cần thay đổi nếu ngôn ngữ đã được chọn
      }
      
      // Lưu trạng thái hiện tại để khôi phục nếu có lỗi
      final previousState = currentState;
      
      // Thông báo đang tải để hiển thị loading indicator
      emit(LanguageLoading());
      
      try {
        // Lưu mã ngôn ngữ mới vào bộ nhớ
        final success = await repository.setLanguageCode(event.languageCode);
        
        if (!success) {
          // Nếu không lưu được, ném lỗi
          throw Exception('Could not save language preference');
        }
        
        // Tìm đối tượng ngôn ngữ tương ứng
        final selectedLanguage = _supportedLanguages.firstWhere(
          (lang) => lang.code == event.languageCode,
          orElse: () => _supportedLanguages.first,
        );
        
        // Cập nhật trạng thái với ngôn ngữ mới
        emit(currentState.copyWith(
          languageCode: event.languageCode,
          selectedLanguage: selectedLanguage,
        ));
      } catch (e) {
        // Khôi phục trạng thái trước đó nếu có lỗi
        emit(previousState);
        
        // Thông báo lỗi
        emit(LanguageError('Failed to change language: ${e.toString()}'));
        
        // Khôi phục trạng thái sau khi hiển thị lỗi
        Future.delayed(const Duration(seconds: 2), () {
          emit(previousState);
        });
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

