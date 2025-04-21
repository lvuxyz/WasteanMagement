// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a vi locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'vi';

  static String m0(username) => "Xin chào, ${username}!";
  static String m1(username) => "Đăng nhập thành công! Xin chào, ${username}";
  static String m2(amount, unit) => "Mục tiêu tháng: ${amount}${unit}";
  static String m3(amount) => "${amount}kg còn lại";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aiWasteScanner": MessageLookupByLibrary.simpleMessage("AI Quét Rác"),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage("Đã có tài khoản?"),
    "analyzingWaste": MessageLookupByLibrary.simpleMessage("Đang phân tích rác..."),
    "appDescription": MessageLookupByLibrary.simpleMessage("Ứng dụng Quản lý Chất thải và Tái chế"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Ứng dụng của tôi"),
    "backToLogin": MessageLookupByLibrary.simpleMessage("Quay Lại Đăng Nhập"),
    "cancel": MessageLookupByLibrary.simpleMessage("Hủy"),
    "cannotDetectWaste": MessageLookupByLibrary.simpleMessage("Không thể nhận diện rác"),
    "changeLanguageContent": MessageLookupByLibrary.simpleMessage("Bạn có muốn thay đổi ngôn ngữ không?"),
    "changeLanguageTitle": MessageLookupByLibrary.simpleMessage("Thay đổi ngôn ngữ"),
    "chooseLanguageSubtitle": MessageLookupByLibrary.simpleMessage("Chọn ngôn ngữ ưa thích của bạn cho ứng dụng"),
    "confirm": MessageLookupByLibrary.simpleMessage("Xác nhận"),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Xác Nhận Mật Khẩu"),
    "confirmPasswordRequired": MessageLookupByLibrary.simpleMessage("Vui lòng xác nhận mật khẩu"),
    "continueButton": MessageLookupByLibrary.simpleMessage("Tiếp tục"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Tạo Tài Khoản"),
    "detectionResults": MessageLookupByLibrary.simpleMessage("Kết quả nhận diện"),
    "detectionSuccess": MessageLookupByLibrary.simpleMessage("Lưu kết quả thành công!"),
    "dontHaveAccount": MessageLookupByLibrary.simpleMessage("Bạn chưa có tài khoản?"),
    "earnPoints": MessageLookupByLibrary.simpleMessage("Tích điểm"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailRequired": MessageLookupByLibrary.simpleMessage("Email là bắt buộc"),
    "english": MessageLookupByLibrary.simpleMessage("Tiếng Anh"),
    "enoughLight": MessageLookupByLibrary.simpleMessage("Ánh sáng đủ sáng để nhìn rõ vật thể"),
    "enterConfirmPassword": MessageLookupByLibrary.simpleMessage("Nhập lại mật khẩu của bạn"),
    "enterEmail": MessageLookupByLibrary.simpleMessage("Nhập địa chỉ email của bạn"),
    "enterFullName": MessageLookupByLibrary.simpleMessage("Nhập họ và tên của bạn"),
    "enterPassword": MessageLookupByLibrary.simpleMessage("Nhập mật khẩu"),
    "enterUsername": MessageLookupByLibrary.simpleMessage("Nhập tên đăng nhập"),
    "enterValidNumber": MessageLookupByLibrary.simpleMessage("Vui lòng nhập số hợp lệ"),
    "enterWeight": MessageLookupByLibrary.simpleMessage("Nhập khối lượng"),
    "errorOccurred": MessageLookupByLibrary.simpleMessage("Đã xảy ra lỗi"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Quên mật khẩu?"),
    "forgotPasswordDescription": MessageLookupByLibrary.simpleMessage("Nhập địa chỉ email của bạn và chúng tôi sẽ gửi cho bạn liên kết để đặt lại mật khẩu"),
    "forgotPasswordTitle": MessageLookupByLibrary.simpleMessage("Quên Mật Khẩu"),
    "fullName": MessageLookupByLibrary.simpleMessage("Họ và Tên"),
    "fullNameRequired": MessageLookupByLibrary.simpleMessage("Họ và tên là bắt buộc"),
    "goBack": MessageLookupByLibrary.simpleMessage("Quay lại"),
    "hello": m0,
    "initializing": MessageLookupByLibrary.simpleMessage("Khởi tạo..."),
    "initializingCamera": MessageLookupByLibrary.simpleMessage("Đang khởi tạo camera..."),
    "invalidEmail": MessageLookupByLibrary.simpleMessage("Vui lòng nhập địa chỉ email hợp lệ"),
    "languageChangeError": MessageLookupByLibrary.simpleMessage("Không thể thay đổi ngôn ngữ"),
    "languageChangeSuccess": MessageLookupByLibrary.simpleMessage("Đã thay đổi ngôn ngữ thành công"),
    "languageChanged": MessageLookupByLibrary.simpleMessage("Đã thay đổi ngôn ngữ thành công"),
    "languageScreenTitle": MessageLookupByLibrary.simpleMessage("Chọn ngôn ngữ"),
    "login": MessageLookupByLibrary.simpleMessage("Đăng Nhập"),
    "loginSuccess": m1,
    "loginTitle": MessageLookupByLibrary.simpleMessage("Đăng nhập"),
    "logout": MessageLookupByLibrary.simpleMessage("Đăng Xuất"),
    "monthlyGoal": m2,
    "noLanguagesFound": MessageLookupByLibrary.simpleMessage("Không tìm thấy ngôn ngữ nào"),
    "objectNotObscured": MessageLookupByLibrary.simpleMessage("Vật thể không bị che khuất"),
    "password": MessageLookupByLibrary.simpleMessage("Mật khẩu"),
    "passwordRequired": MessageLookupByLibrary.simpleMessage("Mật khẩu là bắt buộc"),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage("Mật khẩu không khớp"),
    "placeWasteInCenter": MessageLookupByLibrary.simpleMessage("Rác được đặt ở trung tâm khung hình"),
    "pleaseEnterWeight": MessageLookupByLibrary.simpleMessage("Vui lòng nhập khối lượng"),
    "pleaseTryAgain": MessageLookupByLibrary.simpleMessage("Vui lòng thử lại"),
    "profile": MessageLookupByLibrary.simpleMessage("Hồ Sơ"),
    "quickActions": MessageLookupByLibrary.simpleMessage("Hành động nhanh"),
    "recentActivities": MessageLookupByLibrary.simpleMessage("Hoạt động gần đây"),
    "register": MessageLookupByLibrary.simpleMessage("Đăng Ký"),
    "registrationDescription": MessageLookupByLibrary.simpleMessage("Điền thông tin của bạn để tạo tài khoản mới"),
    "registrationError": MessageLookupByLibrary.simpleMessage("Không thể tạo tài khoản"),
    "registrationSuccess": MessageLookupByLibrary.simpleMessage("Tạo tài khoản thành công"),
    "registrationTitle": MessageLookupByLibrary.simpleMessage("Tạo Tài Khoản"),
    "remainingAmount": m3,
    "rememberMe": MessageLookupByLibrary.simpleMessage("Nhớ mình nha"),
    "resetPassword": MessageLookupByLibrary.simpleMessage("Đặt Lại Mật Khẩu"),
    "resetPasswordError": MessageLookupByLibrary.simpleMessage("Không thể gửi liên kết đặt lại mật khẩu"),
    "resetPasswordSuccess": MessageLookupByLibrary.simpleMessage("Liên kết đặt lại mật khẩu đã được gửi đến email của bạn"),
    "save": MessageLookupByLibrary.simpleMessage("Lưu"),
    "saveResults": MessageLookupByLibrary.simpleMessage("Lưu kết quả"),
    "scanWaste": MessageLookupByLibrary.simpleMessage("Quét rác"),
    "schedule": MessageLookupByLibrary.simpleMessage("Đặt lịch"),
    "searchLanguage": MessageLookupByLibrary.simpleMessage("Tìm kiếm ngôn ngữ"),
    "signUp": MessageLookupByLibrary.simpleMessage("Đăng ký"),
    "totalWasteSorted": MessageLookupByLibrary.simpleMessage("Tổng rác đã phân loại"),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Thử lại"),
    "unit": MessageLookupByLibrary.simpleMessage("Đơn vị"),
    "username": MessageLookupByLibrary.simpleMessage("Tên đăng nhập"),
    "usernameRequired": MessageLookupByLibrary.simpleMessage("Tên đăng nhập là bắt buộc"),
    "vietnamese": MessageLookupByLibrary.simpleMessage("Tiếng Việt"),
    "wasteType": MessageLookupByLibrary.simpleMessage("Loại rác:"),
    "weight": MessageLookupByLibrary.simpleMessage("Khối lượng"),
    "welcomeDescription": MessageLookupByLibrary.simpleMessage("Bây giờ tài khoản của bạn ở cùng một nơi và luôn được kiểm soát"),
    "welcomeSubtitle": MessageLookupByLibrary.simpleMessage("Khám phá ứng dụng"),
    "welcomeTitle": MessageLookupByLibrary.simpleMessage("LVuRác")
  };
}