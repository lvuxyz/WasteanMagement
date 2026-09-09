import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasteanmagement/core/api/api_constants.dart';

void main() {
  group('ApiConstants.baseUrl', () {
    tearDown(dotenv.clean);

    test('dùng hằng dự phòng khi dotenv chưa được nạp', () {
      // dotenv.env ném lỗi nếu truy cập trước khi load, nên baseUrl phải chắn
      // bằng isInitialized — nếu không, mọi unit test chạm tới repository sẽ vỡ.
      expect(dotenv.isInitialized, isFalse);
      expect(ApiConstants.baseUrl, 'http://103.27.239.248:3000/api/v1');
    });

    test('ưu tiên API_BASE_URL trong .env', () {
      dotenv.testLoad(fileInput: 'API_BASE_URL=http://10.0.2.2:3000/api/v1');

      expect(ApiConstants.baseUrl, 'http://10.0.2.2:3000/api/v1');
    });

    test('bỏ qua API_BASE_URL rỗng và quay về hằng dự phòng', () {
      dotenv.testLoad(fileInput: 'API_BASE_URL=');

      expect(ApiConstants.baseUrl, 'http://103.27.239.248:3000/api/v1');
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
