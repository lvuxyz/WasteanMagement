import '../datasources/local_data_source.dart';
import '../../models/language_model.dart';

class LanguageRepository {
  final LocalDataSource localDataSource;

  LanguageRepository({required this.localDataSource});

  // Trong file language_repository.dart
  factory LanguageRepository.create() {
    return LanguageRepository(
      localDataSource: LocalDataSource(),
    );
  }

  // Daftar bahasa yang didukung
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

  // Lấy mã ngôn ngữ đã lưu
  Future<String> getLanguageCode() async {
    return await localDataSource.getLanguageCode();
  }

  // Lưu mã ngôn ngữ
  Future<bool> setLanguageCode(String languageCode) async {
    return await localDataSource.setLanguageCode(languageCode);
  }

  // Lấy danh sách ngôn ngữ được hỗ trợ
  List<Language> getSupportedLanguages() {
    return _supportedLanguages;
  }

  // Lấy thông tin ngôn ngữ theo mã
  Language getLanguageByCode(String code) {
    return _supportedLanguages.firstWhere(
          (language) => language.code == code,
      orElse: () => _supportedLanguages.first,
    );
  }
}