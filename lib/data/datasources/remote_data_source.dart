import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../utils/secure_storage.dart';

class RemoteDataSource {
  final ApiClient apiClient;

  RemoteDataSource({
    required this.apiClient,
  });

  // Tạo factory constructor để dễ khởi tạo
  factory RemoteDataSource.create() {
    final secureStorage = SecureStorage();
    return RemoteDataSource(
      apiClient: ApiClient(
        client: http.Client(),
        secureStorage: secureStorage,
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
        developer.log('Phản hồi đăng nhập: ${responseData.toString()}');

        // Kiểm tra thông báo thành công
        final successMessage = response.message;
        if (successMessage.toLowerCase().contains('thành công') || 
            responseData['status'] == 'success' || 
            (responseData['data'] != null && responseData['data']['status'] == 'success')) {
          
          // Nếu có dữ liệu thì trả về, nếu không thì tạo dữ liệu tạm thời
          if (responseData['data'] != null) {
            return responseData['data'];
          } else {
            // Tạo dữ liệu người dùng tạm thời nếu không có trong phản hồi
            return {
              'token': 'temp_token_${DateTime.now().millisecondsSinceEpoch}',
              'user': {
                'username': username,
                'full_name': username,
                'id': 0,
                'email': '',
              },
            };
          }
        } else {
          throw ServerException(responseData['message'] ?? 'Đăng nhập thất bại');
        }
      } else {
        // Kiểm tra thông báo để phát hiện trường hợp phản hồi chứa "thành công" nhưng bị xử lý như lỗi
        if (response.message.toLowerCase().contains('thành công')) {
          developer.log('Phát hiện đăng nhập thành công từ thông báo lỗi: ${response.message}');
          
          // Trả về dữ liệu tạm thời vì đăng nhập thành công nhưng không có dữ liệu
          return {
            'token': 'temp_token_${DateTime.now().millisecondsSinceEpoch}',
            'user': {
              'username': username,
              'full_name': username,
              'id': 0,
              'email': '',
            },
          };
        }
        
        throw ServerException(response.message);
      }
    } catch (e) {
      // Kiểm tra nếu lỗi chứa thông báo thành công
      if (e.toString().toLowerCase().contains('thành công')) {
        developer.log('Phát hiện đăng nhập thành công từ lỗi: ${e.toString()}');
        
        // Trả về dữ liệu tạm thời vì đăng nhập thành công nhưng không có dữ liệu
        return {
          'token': 'temp_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'username': username,
            'full_name': username,
            'id': 0,
            'email': '',
          },
        };
      }
      
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
      //tra ve thanh cong neu khong co loi
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Lấy thông tin người dùng
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      developer.log('Gọi API lấy thông tin người dùng: ${ApiConstants.profile}');
      final response = await apiClient.get(ApiConstants.profile);

      if (response.isSuccess) {
        // Xử lý phản hồi dựa trên cấu trúc API được cung cấp
        final responseData = response.body;
        developer.log('Phản hồi lấy thông tin người dùng: ${responseData.toString()}');
        
        // Cấu trúc API: { "success": true, "data": { "user": {...} } }
        if (responseData['success'] == true && responseData['data'] != null) {
          if (responseData['data']['user'] != null) {
            return responseData['data']['user'];
          } else {
            return responseData['data'];
          }
        } else if (responseData['user'] != null) {
          // Trường hợp phản hồi trực tiếp là user
          return responseData['user'];
        } else {
          // Trường hợp không tìm thấy dữ liệu trong cấu trúc phản hồi
          throw ServerException('Không tìm thấy dữ liệu người dùng trong phản hồi');
        }
      } else {
        throw ServerException('Lấy thông tin người dùng thất bại: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Lỗi khi lấy thông tin người dùng: ${e.toString()}', error: e);
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