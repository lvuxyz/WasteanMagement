import 'dart:developer' as developer;
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../models/user_model.dart';
import 'package:wasteanmagement/data/datasources/local_data_source.dart';
import 'package:wasteanmagement/data/datasources/remote_data_source.dart';

class UserRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  Future<User> login(String username, String password) async {
    try {
      developer.log('Đang thực hiện đăng nhập với username: $username');
      final response = await remoteDataSource.login(username, password);

      // Lưu token xác thực
      if (response['token'] != null) {
        final token = response['token'];
        developer.log('Token nhận được: ${token.substring(0, min(10, token.length))}...');
        await localDataSource.saveToken(token);
        developer.log('Đã lưu token thành công');
      } else {
        developer.log('CẢNH BÁO: Token không tồn tại trong phản hồi', error: 'Token không tồn tại');
        throw Exception('Đăng nhập thất bại: Token không tồn tại trong phản hồi');
      }

      // Phân tích và lưu cache dữ liệu người dùng
      if (response['user'] != null) {
        final user = User.fromJson(response['user']);
        await localDataSource.cacheUserProfile(user);
        developer.log('Đã lưu thông tin người dùng vào cache: ${user.fullName}');
        return user;
      } else {
        developer.log('CẢNH BÁO: Dữ liệu người dùng không tồn tại trong phản hồi', error: 'Dữ liệu user không tồn tại');
        throw Exception('Đăng nhập thất bại: Dữ liệu người dùng không tồn tại trong phản hồi');
      }
    } on UnauthorizedException catch (e) {
      developer.log('Lỗi xác thực: ${e.toString()}', error: e);
      throw UnauthorizedException('Thông tin đăng nhập không chính xác: ${e.toString()}');
    } catch (e) {
      developer.log('Lỗi đăng nhập: ${e.toString()}', error: e);
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      developer.log('Bắt đầu đăng xuất');
      final token = await localDataSource.getToken();

      if (token != null && await networkInfo.isConnected) {
        try {
          developer.log('Gọi API đăng xuất');
          await remoteDataSource.logout(token);
          developer.log('API đăng xuất thành công');
        } catch (e) {
          developer.log('Không thể gọi API đăng xuất: ${e.toString()}', error: e);
          // Bỏ qua lỗi khi gọi API đăng xuất
        }
      } else {
        developer.log('Đăng xuất cục bộ (không cần gọi API)');
      }

      // Luôn xóa dữ liệu cục bộ
      await localDataSource.deleteToken();
      await localDataSource.clearUserProfile();
      developer.log('Đã xóa dữ liệu đăng nhập cục bộ');
    } catch (e) {
      developer.log('Lỗi khi đăng xuất: ${e.toString()}', error: e);
      // Đảm bảo chúng ta xóa dữ liệu ngay cả khi có lỗi
      try {
        await localDataSource.deleteToken();
        await localDataSource.clearUserProfile();
        developer.log('Đã xóa dữ liệu đăng nhập cục bộ sau khi xảy ra lỗi');
      } catch (clearError) {
        developer.log('Không thể xóa dữ liệu cục bộ: ${clearError.toString()}', error: clearError);
      }
    }
  }

  // Phương thức hồ sơ người dùng
  Future<User> getUserProfile() async {
    try {
      developer.log('Bắt đầu lấy thông tin hồ sơ người dùng');
      // Kiểm tra kết nối
      if (await networkInfo.isConnected) {
        try {
          final token = await localDataSource.getToken();
          developer.log('Token hiện tại: ${token != null ? (token.substring(0, min(10, token.length)) + "...") : "null"}');

          if (token == null) {
            developer.log('Token không tồn tại, thử lấy từ cache');
            final cachedUser = await localDataSource.getCachedUserProfile();
            if (cachedUser != null) {
              developer.log('Đã lấy thông tin người dùng từ cache: ${cachedUser.fullName}');
              return cachedUser;
            }
            throw UnauthorizedException('Người dùng chưa đăng nhập');
          }

          developer.log('Gọi API lấy thông tin người dùng');
          final userData = await remoteDataSource.getUserProfile();
          final user = User.fromJson(userData);

          // Cập nhật cache
          await localDataSource.cacheUserProfile(user);
          developer.log('Đã lấy và cập nhật thông tin người dùng: ${user.fullName}');

          return user;
        } on UnauthorizedException catch (e) {
          developer.log('Lỗi xác thực khi lấy thông tin, thử dùng cache: ${e.toString()}', error: e);
          // Nếu token không hợp lệ, thử dùng dữ liệu đã lưu trong cache
          final cachedUser = await localDataSource.getCachedUserProfile();
          if (cachedUser != null) {
            developer.log('Đã lấy thông tin người dùng từ cache: ${cachedUser.fullName}');
            return cachedUser;
          }

          // Nếu không có dữ liệu cache, xóa token không hợp lệ để tránh lỗi tiếp theo
          await localDataSource.deleteToken();
          developer.log('Đã xóa token không hợp lệ');

          throw UnauthorizedException('Token xác thực không hợp lệ hoặc đã hết hạn');
        } catch (e) {
          developer.log('Lỗi khác khi lấy thông tin, thử dùng cache: ${e.toString()}', error: e);
          // Với các lỗi khác, thử dùng dữ liệu đã lưu trong cache
          final cachedUser = await localDataSource.getCachedUserProfile();
          if (cachedUser != null) {
            developer.log('Đã lấy thông tin người dùng từ cache: ${cachedUser.fullName}');
            return cachedUser;
          }
          throw Exception('Lấy thông tin người dùng thất bại: ${e.toString()}');
        }
      } else {
        developer.log('Không có kết nối mạng, sử dụng dữ liệu cache');
        // Không có kết nối, sử dụng dữ liệu đã lưu trong cache
        final cachedUser = await localDataSource.getCachedUserProfile();
        if (cachedUser != null) {
          developer.log('Đã lấy thông tin người dùng từ cache: ${cachedUser.fullName}');
          return cachedUser;
        }
        throw Exception('Không có kết nối mạng và không có dữ liệu đã lưu');
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        developer.log('Lỗi xác thực cuối cùng: ${e.toString()}', error: e);
        rethrow;
      }
      developer.log('Lỗi lấy thông tin người dùng: ${e.toString()}', error: e);
      throw Exception('Lấy thông tin người dùng thất bại: ${e.toString()}');
    }
  }

  Future<User> updateUserProfile({
    String? fullName,
    String? email,
    String? phone,
    String? address,
  }) async {
    try {
      developer.log('Bắt đầu cập nhật thông tin người dùng');
      if (!await networkInfo.isConnected) {
        developer.log('Không có kết nối mạng');
        throw Exception('Không có kết nối mạng');
      }

      final token = await localDataSource.getToken();
      if (token == null) {
        developer.log('Token không tồn tại khi cập nhật hồ sơ');
        throw UnauthorizedException('Người dùng chưa đăng nhập');
      }

      // Tạo body request với các thông tin cần cập nhật
      final Map<String, dynamic> requestBody = {};
      if (fullName != null) requestBody['full_name'] = fullName;
      if (email != null) requestBody['email'] = email;
      if (phone != null) requestBody['phone'] = phone;
      if (address != null) requestBody['address'] = address;

      developer.log('Gọi API cập nhật thông tin: $requestBody');
      final userData = await remoteDataSource.updateUserProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
      );

      final updatedUser = User.fromJson(userData);

      // Cập nhật cache
      await localDataSource.cacheUserProfile(updatedUser);
      developer.log('Đã cập nhật thông tin người dùng: ${updatedUser.fullName}');

      return updatedUser;
    } catch (e) {
      developer.log('Lỗi cập nhật thông tin người dùng: ${e.toString()}', error: e);
      if (e is UnauthorizedException) rethrow;
      throw Exception('Cập nhật thông tin người dùng thất bại: ${e.toString()}');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      developer.log('Bắt đầu thay đổi mật khẩu');
      if (!await networkInfo.isConnected) {
        developer.log('Không có kết nối mạng');
        throw Exception('Không có kết nối mạng');
      }

      final token = await localDataSource.getToken();
      if (token == null) {
        developer.log('Token không tồn tại khi thay đổi mật khẩu');
        throw UnauthorizedException('Người dùng chưa đăng nhập');
      }

      developer.log('Gọi API thay đổi mật khẩu');
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      developer.log('Đã thay đổi mật khẩu thành công');
    } catch (e) {
      developer.log('Lỗi thay đổi mật khẩu: ${e.toString()}', error: e);
      if (e is UnauthorizedException) rethrow;
      throw Exception('Thay đổi mật khẩu thất bại: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      developer.log('Bắt đầu yêu cầu đặt lại mật khẩu cho email: $email');
      if (!await networkInfo.isConnected) {
        developer.log('Không có kết nối mạng');
        throw Exception('Không có kết nối mạng');
      }

      developer.log('Gọi API đặt lại mật khẩu');
      await remoteDataSource.forgotPassword(email);
      developer.log('Đã gửi yêu cầu đặt lại mật khẩu thành công');
    } catch (e) {
      developer.log('Lỗi đặt lại mật khẩu: ${e.toString()}', error: e);
      throw Exception('Yêu cầu đặt lại mật khẩu thất bại: ${e.toString()}');
    }
  }

  // Quản lý phiên
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getToken();
    developer.log('Kiểm tra đăng nhập: Token ${token != null ? "tồn tại" : "không tồn tại"}');
    return token != null;
  }

  // Hàm tiện ích
  int min(int a, int b) {
    return a < b ? a : b;
  }
}