import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../models/user_model.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';

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
      final response = await remoteDataSource.login(username, password);

      // Lưu token xác thực
      if (response['token'] != null) {
        await localDataSource.saveToken(response['token']);
      }

      // Phân tích và lưu cache dữ liệu người dùng
      final user = User.fromJson(response['user']);
      await localDataSource.cacheUserProfile(user);

      return user;
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }


  Future<void> logout() async {
    try {
      final token = await localDataSource.getToken();

      if (token != null && await networkInfo.isConnected) {
        try {
          await remoteDataSource.logout(token);
        } catch (e) {
          // Bỏ qua lỗi khi gọi API đăng xuất
        }
      }

      // Luôn xóa dữ liệu cục bộ
      await localDataSource.deleteToken();
      await localDataSource.clearUserProfile();
    } catch (e) {
      // Đảm bảo chúng ta xóa dữ liệu ngay cả khi có lỗi
      await localDataSource.deleteToken();
      await localDataSource.clearUserProfile();
    }
  }

  // Phương thức hồ sơ người dùng
  Future<User> getUserProfile() async {
    try {
      // Kiểm tra kết nối
      if (await networkInfo.isConnected) {
        try {
          final token = await localDataSource.getToken();

          if (token == null) {
            throw UnauthorizedException('Người dùng chưa đăng nhập');
          }

          final userData = await remoteDataSource.getUserProfile();
          final user = User.fromJson(userData);

          // Cập nhật cache
          await localDataSource.cacheUserProfile(user);

          return user;
        } on UnauthorizedException {
          // Nếu token không hợp lệ, thử dùng dữ liệu đã lưu trong cache
          final cachedUser = await localDataSource.getCachedUserProfile();
          if (cachedUser != null) {
            return cachedUser;
          }
          rethrow;
        } catch (e) {
          // Với các lỗi khác, thử dùng dữ liệu đã lưu trong cache
          final cachedUser = await localDataSource.getCachedUserProfile();
          if (cachedUser != null) {
            return cachedUser;
          }
          throw Exception('Lấy thông tin người dùng thất bại: ${e.toString()}');
        }
      } else {
        // Không có kết nối, sử dụng dữ liệu đã lưu trong cache
        final cachedUser = await localDataSource.getCachedUserProfile();
        if (cachedUser != null) {
          return cachedUser;
        }
        throw Exception('Không có kết nối mạng và không có dữ liệu đã lưu');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
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
      if (!await networkInfo.isConnected) {
        throw Exception('Không có kết nối mạng');
      }

      final token = await localDataSource.getToken();

      if (token == null) {
        throw UnauthorizedException('Người dùng chưa đăng nhập');
      }

      final userData = await remoteDataSource.updateUserProfile();

      final updatedUser = User.fromJson(userData);

      // Cập nhật cache
      await localDataSource.cacheUserProfile(updatedUser);

      return updatedUser;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw Exception('Cập nhật thông tin người dùng thất bại: ${e.toString()}');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      if (!await networkInfo.isConnected) {
        throw Exception('Không có kết nối mạng');
      }

      final token = await localDataSource.getToken();

      if (token == null) {
        throw UnauthorizedException('Người dùng chưa đăng nhập');
      }

      await remoteDataSource.updateUserProfile();
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw Exception('Thay đổi mật khẩu thất bại: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      if (!await networkInfo.isConnected) {
        throw Exception('Không có kết nối mạng');
      }

      await remoteDataSource.forgotPassword(email);
    } catch (e) {
      throw Exception('Yêu cầu đặt lại mật khẩu thất bại: ${e.toString()}');
    }
  }

  // Quản lý phiên
  Future<bool> isLoggedIn() async {
    return await localDataSource.getToken() != null;
  }
}