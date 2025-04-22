import 'package:http/http.dart' as http;
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../models/user_model.dart';
import '../../utils/secure_storage.dart';

class RemoteDataSource {
  final ApiClient apiClient;

  RemoteDataSource({
    required this.apiClient,
  });

  // Tạo factory constructor để dễ khởi tạo
  factory RemoteDataSource.create() {
    return RemoteDataSource(
      apiClient: ApiClient(
        client: http.Client(),
        secureStorage: SecureStorage(),
      ),
    );
  }

  // Đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await apiClient.post(
        ApiConstants.login,
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.isSuccess) {
        // Cấu trúc dữ liệu trả về đã thay đổi
        final responseData = response.body;

        if (responseData['status'] == 'success') {
          return responseData['data'];
        } else {
          throw ServerException(responseData['message'] ?? 'Đăng nhập thất bại');
        }
      } else {
        throw ServerException(response.message);
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // Đăng xuất
  Future<void> logout(String token) async {
    try {
      final response = await apiClient.post(ApiConstants.logout);

      if (!response.isSuccess) {
        throw ServerException('Đăng xuất thất bại: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Lấy thông tin người dùng
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await apiClient.get(ApiConstants.profile);

      if (response.isSuccess) {
        return response.body;
      } else {
        throw ServerException('Lấy thông tin người dùng thất bại: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // Cập nhật thông tin người dùng
  Future<Map<String, dynamic>> updateUserProfile({
    String? fullName,
    String? email,
    String? phone,
    String? address,
  }) async {
    final Map<String, dynamic> requestBody = {};

    if (fullName != null) requestBody['full_name'] = fullName;
    if (email != null) requestBody['email'] = email;
    if (phone != null) requestBody['phone'] = phone;
    if (address != null) requestBody['address'] = address;

    try {
      final response = await apiClient.put(
        ApiConstants.updateProfile,
        body: requestBody,
      );

      if (response.isSuccess) {
        return response.body;
      } else {
        throw ServerException('Cập nhật thông tin người dùng thất bại: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // Đổi mật khẩu
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.changePassword,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (!response.isSuccess) {
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Thay đổi mật khẩu thất bại: ${response.statusCode}';
        throw ServerException(errorMessage);
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // Quên mật khẩu
  Future<void> forgotPassword(String email) async {
    try {
      final response = await apiClient.post(
        ApiConstants.forgotPassword,
        body: {'email': email},
      );

      if (!response.isSuccess) {
        throw ServerException('Yêu cầu đặt lại mật khẩu thất bại: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Đăng ký tài khoản
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.register,
        body: {
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );

      if (response.isSuccess) {
        return response.body;
      } else {
        throw ServerException('Đăng ký tài khoản thất bại: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}