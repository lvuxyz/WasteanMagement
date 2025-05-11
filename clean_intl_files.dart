import 'dart:io';

import 'package:flutter/foundation.dart';

void main() {
  const String libL10nDir = 'lib/l10n';
  const String rootL10nDir = 'l10n';
  
  try {
    // Kiểm tra và xóa file intl_en.arb trong thư mục lib/l10n
    final libIntlFile = File('$libL10nDir/intl_en.arb');
    if (libIntlFile.existsSync()) {
      debugPrint('Xóa file $libL10nDir/intl_en.arb');
      libIntlFile.deleteSync();
    }
    
    // Kiểm tra và xóa file intl_en.arb trong thư mục l10n
    final rootIntlFile = File('$rootL10nDir/intl_en.arb');
    if (rootIntlFile.existsSync()) {
      debugPrint('Xóa file $rootL10nDir/intl_en.arb');
      rootIntlFile.deleteSync();
    }

    debugPrint('Hoàn tất kiểm tra và xóa các file intl_en.arb không mong muốn');
  } catch (e) {
    debugPrint('Lỗi khi xóa file: $e');
  }
} 