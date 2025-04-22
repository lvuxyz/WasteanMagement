import 'dart:io';

void main() {
  final String libL10nDir = 'lib/l10n';
  final String rootL10nDir = 'l10n';
  
  try {
    // Kiểm tra và xóa file intl_en.arb trong thư mục lib/l10n
    final libIntlFile = File('$libL10nDir/intl_en.arb');
    if (libIntlFile.existsSync()) {
      print('Xóa file $libL10nDir/intl_en.arb');
      libIntlFile.deleteSync();
    }
    
    // Kiểm tra và xóa file intl_en.arb trong thư mục l10n
    final rootIntlFile = File('$rootL10nDir/intl_en.arb');
    if (rootIntlFile.existsSync()) {
      print('Xóa file $rootL10nDir/intl_en.arb');
      rootIntlFile.deleteSync();
    }
    
    print('Hoàn tất kiểm tra và xóa các file intl_en.arb không mong muốn');
  } catch (e) {
    print('Lỗi khi xóa file: $e');
  }
} 