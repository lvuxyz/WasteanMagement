import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Mức độ quan trọng của một dòng log, xếp theo thứ tự tăng dần.
enum LogLevel { debug, info, warn, error }

extension _LogLevelInfo on LogLevel {
  /// Ký hiệu một ký tự ở đầu dòng log cho dễ quét mắt.
  String get mark {
    switch (this) {
      case LogLevel.debug:
        return 'D';
      case LogLevel.info:
        return 'I';
      case LogLevel.warn:
        return 'W';
      case LogLevel.error:
        return 'E';
    }
  }

  /// Mức tương ứng của `dart:developer` để DevTools lọc và tô màu đúng.
  int get developerLevel {
    switch (this) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warn:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}

/// Log tập trung cho toàn app.
///
/// Ba vấn đề của cách log cũ (gọi thẳng `developer.log` ở khắp nơi) mà lớp này
/// giải quyết:
///
/// 1. **Trùng lặp**: cùng một sự kiện bị log lại ở nhiều tầng (api client →
///    repository → bloc → screen). [_shouldSuppress] gộp các dòng giống hệt
///    nhau xảy ra sát nhau thành một dòng kèm số lần lặp.
/// 2. **Nhiễu**: token, header, JSON dài đổ nguyên vào console. [maskToken],
///    [preview] và [shortUrl] rút gọn phần không cần nhìn.
/// 3. **Khó lần theo**: không biết dòng log đến từ đâu. Mọi hàm đều bắt buộc
///    có `tag`, in ra thành `[Tag]` ở đầu dòng.
///
/// Ở bản release log bị tắt hẳn ([minLevel] = null) để không lộ dữ liệu người
/// dùng và không tốn chi phí dựng chuỗi.
class AppLogger {
  AppLogger._();

  /// Ngưỡng log: dòng có mức thấp hơn sẽ bị bỏ qua.
  ///
  /// `null` nghĩa là tắt hẳn. Mặc định: debug khi chạy debug/profile, tắt khi
  /// release. Có thể đổi lúc chạy, ví dụ trong `main()` khi cần bớt ồn:
  /// `AppLogger.minLevel = LogLevel.info;`
  static LogLevel? minLevel = kReleaseMode ? null : LogLevel.debug;

  /// Bật/tắt cột giờ ở đầu dòng log.
  static bool showTime = true;

  /// Khoảng thời gian coi hai dòng log giống hệt nhau là "lặp".
  static Duration dedupeWindow = const Duration(seconds: 5);

  /// Độ dài tối đa của phần dữ liệu đính kèm trước khi bị cắt bớt.
  static int maxDataLength = 300;

  static final Map<String, _DedupeEntry> _recent = {};

  static void d(String tag, String message, {Object? data}) =>
      _log(LogLevel.debug, tag, message, data: data);

  static void i(String tag, String message, {Object? data}) =>
      _log(LogLevel.info, tag, message, data: data);

  static void w(String tag, String message, {Object? data}) =>
      _log(LogLevel.warn, tag, message, data: data);

  static void e(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(LogLevel.error, tag, message, error: error, stackTrace: stackTrace);

  /// Log một request sắp gửi đi: `→ GET /waste-types`.
  static void request(String method, String url, {Object? body}) {
    _log(
      LogLevel.debug,
      'API',
      '→ $method ${shortUrl(url)}',
      data: body == null ? null : 'body=${preview(body)}',
    );
  }

  /// Log kết quả của một request. Thành công in ở mức debug, thất bại in ở mức
  /// warn kèm thông điệp lỗi rút gọn của server.
  static void response(
    String method,
    String url,
    int statusCode, {
    int? elapsedMs,
    int? bodyLength,
    String? errorMessage,
  }) {
    final meta = <String>[
      if (bodyLength != null) '${bodyLength}B',
      if (elapsedMs != null) '${elapsedMs}ms',
    ];
    final suffix = meta.isEmpty ? '' : ' (${meta.join(', ')})';
    final ok = statusCode >= 200 && statusCode < 400;
    final reason = errorMessage == null || errorMessage.isEmpty
        ? ''
        : ' · ${_clip(errorMessage, 160)}';

    _log(
      ok ? LogLevel.debug : LogLevel.warn,
      'API',
      '${ok ? '←' : 'x'} $statusCode $method ${shortUrl(url)}$suffix$reason',
    );
  }

  /// Bỏ phần `scheme://host/api/v1` cho URL gọn lại, chỉ giữ đường dẫn.
  static String shortUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority) return url;
    final path = uri.path.replaceFirst(RegExp(r'^/api/v\d+'), '');
    final query = uri.query.isEmpty ? '' : '?${uri.query}';
    return '${path.isEmpty ? '/' : path}$query';
  }

  /// Che token, chỉ giữ vài ký tự đầu/cuối để đối chiếu khi cần.
  static String maskToken(String? token) {
    if (token == null || token.isEmpty) return '<không có>';
    if (token.length <= 16) return '***';
    return '${token.substring(0, 8)}…${token.substring(token.length - 4)}'
        ' (${token.length} ký tự)';
  }

  /// Rút gọn dữ liệu đính kèm về [maxDataLength] ký tự, tự che các trường nhạy
  /// cảm (token, mật khẩu) nếu đó là Map.
  static String preview(Object? data, {int? maxLength}) {
    if (data == null) return 'null';
    final sanitized = data is Map ? _sanitize(data) : data;
    String text;
    try {
      text = sanitized is String ? sanitized : jsonEncode(sanitized);
    } catch (_) {
      text = sanitized.toString();
    }
    return _clip(text, maxLength ?? maxDataLength);
  }

  static const Set<String> _sensitiveKeys = {
    'token',
    'accesstoken',
    'refreshtoken',
    'authorization',
    'password',
    'newpassword',
    'oldpassword',
    'confirmpassword',
  };

  static Map<String, dynamic> _sanitize(Map<dynamic, dynamic> source) {
    return source.map((key, value) {
      final name = key.toString();
      final normalized = name.toLowerCase().replaceAll(RegExp(r'[-_]'), '');
      if (_sensitiveKeys.contains(normalized)) {
        return MapEntry(name, maskToken(value?.toString()));
      }
      if (value is Map) return MapEntry(name, _sanitize(value));
      return MapEntry(name, value);
    });
  }

  static String _clip(String text, int maxLength) {
    final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.length <= maxLength) return flat;
    return '${flat.substring(0, maxLength)}… (+${flat.length - maxLength} ký tự)';
  }

  static void _log(
    LogLevel level,
    String tag,
    String message, {
    Object? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final threshold = minLevel;
    if (threshold == null || level.index < threshold.index) return;

    final body = data == null ? message : '$message · ${preview(data)}';
    if (_shouldSuppress(level, tag, body)) return;

    final repeats = _takeRepeatCount(level, tag, body);
    final repeatNote = repeats > 1 ? ' (×$repeats)' : '';
    final time = showTime ? '${_formatTime(DateTime.now())} ' : '';

    developer.log(
      '$time${level.mark} $body$repeatNote',
      name: tag,
      level: level.developerLevel,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Gộp các dòng giống hệt nhau trong [dedupeWindow]: dòng đầu tiên được in,
  /// các dòng sau chỉ cộng dồn bộ đếm và hiện lại dưới dạng `(×N)` ở lần in
  /// tiếp theo sau khi hết cửa sổ.
  static bool _shouldSuppress(LogLevel level, String tag, String body) {
    final key = '${level.index}|$tag|$body';
    final now = DateTime.now();
    final entry = _recent[key];

    if (entry != null && now.difference(entry.lastSeen) < dedupeWindow) {
      entry.lastSeen = now;
      entry.pending++;
      return true;
    }

    _recent[key] = _DedupeEntry(lastSeen: now, pending: entry?.pending ?? 0);
    _evictExpired(now);
    return false;
  }

  static int _takeRepeatCount(LogLevel level, String tag, String body) {
    final entry = _recent['${level.index}|$tag|$body'];
    if (entry == null) return 1;
    final count = entry.pending + 1;
    entry.pending = 0;
    return count;
  }

  static void _evictExpired(DateTime now) {
    if (_recent.length < 64) return;
    _recent.removeWhere(
      (_, entry) => now.difference(entry.lastSeen) > dedupeWindow * 4,
    );
  }

  static String _formatTime(DateTime time) {
    String pad(int value, [int width = 2]) =>
        value.toString().padLeft(width, '0');
    return '${pad(time.hour)}:${pad(time.minute)}:${pad(time.second)}'
        '.${pad(time.millisecond, 3)}';
  }

  /// Xóa lịch sử gộp trùng — dùng trong test để các case không ảnh hưởng nhau.
  @visibleForTesting
  static void resetDedupe() => _recent.clear();
}

class _DedupeEntry {
  _DedupeEntry({required this.lastSeen, required this.pending});

  DateTime lastSeen;
  int pending;
}
