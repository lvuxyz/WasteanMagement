import 'package:shared_preferences/shared_preferences.dart';

class LanguageRepository {
  static const String languageCodeKey = 'languageCode';
  
  // Lấy mã ngôn ngữ đã lưu
  Future<String> getLanguageCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(languageCodeKey) ?? 'en'; // Mặc định là tiếng Anh
  }
  
  // Lưu mã ngôn ngữ
  Future<bool> setLanguageCode(String languageCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(languageCodeKey, languageCode);
  }
} 

