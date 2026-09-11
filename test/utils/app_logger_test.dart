import 'package:flutter_test/flutter_test.dart';
import 'package:wasteanmagement/utils/app_logger.dart';

void main() {
  setUp(AppLogger.resetDedupe);

  group('AppLogger.shortUrl', () {
    test('bỏ host và tiền tố /api/v1 để dòng log chỉ còn đường dẫn', () {
      expect(
        AppLogger.shortUrl('http://192.168.1.3:5001/api/v1/waste-types'),
        '/waste-types',
      );
    });

    test('giữ lại query string vì đó là thông tin cần khi đọc log', () {
      expect(
        AppLogger.shortUrl(
            'http://192.168.1.3:5001/api/v1/transactions/my-transactions?page=1&limit=3'),
        '/transactions/my-transactions?page=1&limit=3',
      );
    });

    test('trả nguyên chuỗi khi không phải URL đầy đủ', () {
      expect(AppLogger.shortUrl('/waste-types'), '/waste-types');
    });
  });

  group('AppLogger.maskToken', () {
    test('chỉ giữ đầu/cuối token để đối chiếu mà không lộ token', () {
      const token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjB9.97hnnDWUXtmxTA6xri9AV7';
      final masked = AppLogger.maskToken(token);

      expect(masked.contains(token), isFalse);
      expect(masked.startsWith('eyJhbGci'), isTrue);
      expect(masked.contains('${token.length} ký tự'), isTrue);
    });

    test('token rỗng hoặc null được ghi rõ là không có', () {
      expect(AppLogger.maskToken(null), '<không có>');
      expect(AppLogger.maskToken(''), '<không có>');
    });
  });

  group('AppLogger.preview', () {
    test('che các trường nhạy cảm trong Map', () {
      final preview = AppLogger.preview({
        'username': 'admin',
        'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload.signature',
        'password': 'sieu-bi-mat',
      });

      expect(preview.contains('admin'), isTrue);
      expect(preview.contains('sieu-bi-mat'), isFalse);
      expect(preview.contains('signature'), isFalse);
    });

    test('che cả trường nhạy cảm nằm sâu bên trong', () {
      final preview = AppLogger.preview({
        'data': {
          'user': {'username': 'admin'},
          'access_token': 'abcdefghijklmnopqrstuvwxyz',
        },
      });

      expect(preview.contains('abcdefghijklmnopqrstuvwxyz'), isFalse);
    });

    test('cắt bớt dữ liệu quá dài và ghi rõ số ký tự bị cắt', () {
      final preview = AppLogger.preview('x' * 500, maxLength: 100);

      expect(preview.length, lessThan(140));
      expect(preview.contains('+400 ký tự'), isTrue);
    });
  });
}
