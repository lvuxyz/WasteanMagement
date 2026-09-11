import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasteanmagement/core/api/api_constants.dart';

void main() {
  group('ApiConstants.baseUrl', () {
    tearDown(dotenv.clean);

    // Không so bằng URL cụ thể: máy chủ đang chọn và IP LAN đổi thường xuyên,
    // gắn cứng giá trị sẽ khiến test vỡ mỗi lần đổi mạng chứ không bắt được
    // lỗi thật. Chỉ ràng buộc phần dễ sai khi sửa tay: có scheme và đúng đuôi
    // '/api/v1', không có dấu '/' thừa.
    final baseUrlShape = matches(r'^https?://[^/]+/api/v1$');

    test('dùng hằng dự phòng khi dotenv chưa được nạp', () {
      // dotenv.env ném lỗi nếu truy cập trước khi load, nên baseUrl phải chắn
      // bằng isInitialized — nếu không, mọi unit test chạm tới repository sẽ vỡ.
      expect(dotenv.isInitialized, isFalse);
      expect(ApiConstants.baseUrl, baseUrlShape);
    });

    test('ưu tiên API_BASE_URL trong .env', () {
      dotenv.testLoad(fileInput: 'API_BASE_URL=http://10.0.2.2:3000/api/v1');

      expect(ApiConstants.baseUrl, 'http://10.0.2.2:3000/api/v1');
    });

    test('bỏ qua API_BASE_URL rỗng và quay về hằng dự phòng', () {
      dotenv.testLoad(fileInput: 'API_BASE_URL=');

      expect(ApiConstants.baseUrl, baseUrlShape);
    });

    test('đổi localhost thành 10.0.2.2 để emulator Android gọi được máy dev', () {
      // defaultTargetPlatform trong test mặc định là android, đúng môi trường
      // duy nhất cần remap.
      dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost:5001/api/v1');

      expect(ApiConstants.baseUrl, 'http://10.0.2.2:5001/api/v1');
    });

    test('giữ nguyên host không phải loopback', () {
      dotenv.testLoad(fileInput: 'API_BASE_URL=http://192.168.1.10:5001/api/v1');

      expect(ApiConstants.baseUrl, 'http://192.168.1.10:5001/api/v1');
    });

    test("cắt dấu '/' thừa ở cuối để không sinh ra '//' khi nối endpoint", () {
      dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example.com/api/v1/');

      expect(ApiConstants.baseUrl, 'https://api.example.com/api/v1');
      expect(ApiConstants.login, 'https://api.example.com/api/v1/auth/login');
    });

    test('các endpoint dẫn xuất bám theo baseUrl từ .env', () {
      dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example.com/api/v1');

      expect(ApiConstants.wasteTypes, 'https://api.example.com/api/v1/waste-types');
      expect(
        ApiConstants.wasteTypeDetail(7),
        'https://api.example.com/api/v1/waste-types/7',
      );
      expect(
        ApiConstants.myTransactions,
        'https://api.example.com/api/v1/transactions/my-transactions',
      );
    });
  });
}
