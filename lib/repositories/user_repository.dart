import '../core/error/exceptions.dart';
import '../core/network/network_info.dart';
import '../models/user_model.dart';
import '../data/datasources/local_data_source.dart';
import '../data/datasources/remote_data_source.dart';
import '../core/api/api_constants.dart';
import '../utils/app_logger.dart';

class UserRepository {
  static const String _tag = 'User';

  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  // Add cache variables
  User? _cachedUser;
  DateTime? _lastFetchTime;
  static const int _cacheDurationSeconds = 10; // Cache for 10 seconds

  UserRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  Future<User> login(String username, String password) async {
    try {
      AppLogger.d(_tag, 'Đăng nhập · username=$username');
      final response = await remoteDataSource.login(username, password);

      // Lưu token xác thực
      if (response['token'] != null) {
        final token = response['token'];
        await localDataSource.saveToken(token);
      } else {
        AppLogger.e(_tag, 'Đăng nhập thất bại: phản hồi không có token');
        throw Exception('Đăng nhập thất bại: Token không tồn tại trong phản hồi');
      }

      // Phân tích và lưu cache dữ liệu người dùng
      if (response['user'] != null) {
        final user = User.fromJson(response['user']);
        await localDataSource.cacheUserProfile(user);
        AppLogger.i(_tag,
            'Đăng nhập thành công · username=$username, fullName=${user.fullName}, id=${user.id}');
        return user;
      } else {
        AppLogger.e(_tag, 'Đăng nhập thất bại: phản hồi không có dữ liệu người dùng');
        throw Exception('Đăng nhập thất bại: Dữ liệu người dùng không tồn tại trong phản hồi');
      }
    } on UnauthorizedException catch (e) {
      AppLogger.w(_tag, 'Sai thông tin đăng nhập · $e');
      throw UnauthorizedException('Thông tin đăng nhập không chính xác: ${e.toString()}');
    } catch (e) {
      // Kiểm tra nếu lỗi là về "Đăng nhập thành công"
      if (e.toString().contains('Đăng nhập thành công')) {
        AppLogger.w(_tag, 'Đăng nhập thành công nhưng server trả về dạng lỗi · $e');

        // Tạo một User giả định để trả về trong trường hợp này
        // Phải đảm bảo rằng đã có token được lưu trước đó
        // Hoặc truy vấn thông tin người dùng hiện tại
        try {
          final cachedUser = await localDataSource.getCachedUserProfile();
          if (cachedUser != null) {
            AppLogger.i(_tag, 'Dùng hồ sơ trong cache: ${cachedUser.fullName}');
            return cachedUser;
          }

          // Nếu không có dữ liệu cache, tạo một user tạm thời
          final tempUser = User(
            id: 0,
            username: username,
            fullName: username, // Sử dụng username làm fullName tạm thời
            email: '',
          );

          await localDataSource.cacheUserProfile(tempUser);
          AppLogger.w(_tag, 'Tạo hồ sơ tạm từ username: ${tempUser.fullName}');
          return tempUser;
        } catch (cacheError) {
          AppLogger.e(_tag, 'Không đọc được hồ sơ trong cache', error: cacheError);
          throw Exception('Đăng nhập thất bại: Không thể lấy thông tin người dùng sau khi đăng nhập thành công');
        }
      }

      AppLogger.e(_tag, 'Đăng nhập thất bại', error: e);
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.d(_tag, 'Bắt đầu đăng xuất');
      final token = await localDataSource.getToken();

      if (token != null && await networkInfo.isConnected) {
        try {
          await remoteDataSource.logout(token);
        } catch (e) {
          AppLogger.w(_tag, 'API đăng xuất lỗi, vẫn xóa dữ liệu cục bộ · $e');
          // Bỏ qua lỗi khi gọi API đăng xuất
        }
      } else {
        AppLogger.d(_tag, 'Đăng xuất cục bộ (không gọi API)');
      }

      // Luôn xóa dữ liệu cục bộ
      await localDataSource.deleteToken();
      await localDataSource.clearUserProfile();
      AppLogger.i(_tag, 'Đã đăng xuất, xóa token và hồ sơ cục bộ');
    } catch (e) {
      AppLogger.e(_tag, 'Lỗi khi đăng xuất', error: e);
      // Đảm bảo chúng ta xóa dữ liệu ngay cả khi có lỗi
      try {
        await localDataSource.deleteToken();
        await localDataSource.clearUserProfile();
        AppLogger.i(_tag, 'Đã xóa token và hồ sơ cục bộ sau khi lỗi');
      } catch (clearError) {
        AppLogger.e(_tag, 'Không xóa được dữ liệu cục bộ', error: clearError);
      }
    }
  }

  Future<User> getUserProfile() async {
    try {
      // Check if we have a valid cache
      final now = DateTime.now();
      if (_cachedUser != null && _lastFetchTime != null) {
        final cacheDuration = now.difference(_lastFetchTime!);
        if (cacheDuration.inSeconds < _cacheDurationSeconds) {
          AppLogger.d(_tag,
              'Hồ sơ lấy từ cache trong bộ nhớ (${cacheDuration.inSeconds}s trước)');
          return _cachedUser!;
        }
      }

      AppLogger.d(_tag, 'Lấy hồ sơ người dùng mới');

      // Kiểm tra kết nối
      if (await networkInfo.isConnected) {
        try {
          final token = await localDataSource.getToken();

          if (token == null) {
            final cachedUser = await localDataSource.getCachedUserProfile();
            if (cachedUser != null) {
              _logCacheFallback(cachedUser, 'chưa có token');
              _updateCache(cachedUser);
              return cachedUser;
            }
            throw UnauthorizedException('Người dùng chưa đăng nhập');
          }

          try {
            final response = await remoteDataSource.getUserProfile();

            // Check if we have the new response format with 'success' and 'data' fields
            if (response.containsKey('success') && response.containsKey('data')) {
              if (response['success'] && response['data'] != null) {
                // For new profile format, just return the raw data to be processed by ProfileBloc
                // We'll create a minimal User object to satisfy the return type
                final basicInfo = response['data']['basic_info'] ?? {};

                // Kiểm tra và xử lý trường roles
                List<String> roles = [];
                if (basicInfo['roles'] != null) {
                  if (basicInfo['roles'] is List) {
                    roles = List<String>.from(basicInfo['roles']);
                  } else if (basicInfo['roles'] is String) {
                    // Nếu roles là string, chuyển thành list
                    roles = [basicInfo['roles']];
                  }
                } else if (response['data']['roles'] != null) {
                  // Thử lấy roles từ cấp cao hơn nếu có
                  if (response['data']['roles'] is List) {
                    roles = List<String>.from(response['data']['roles']);
                  } else if (response['data']['roles'] is String) {
                    roles = [response['data']['roles']];
                  }
                }

                // Nếu vẫn không có roles, mặc định thêm role USER
                if (roles.isEmpty) {
                  roles = ['USER'];
                  AppLogger.d(_tag, 'API không trả về roles, mặc định dùng USER');
                }

                final user = User(
                  id: basicInfo['id'] ?? 0,
                  username: basicInfo['username'] ?? '',
                  fullName: basicInfo['full_name'] ?? '',
                  email: basicInfo['email'] ?? '',
                  phone: basicInfo['phone'] ?? '',
                  address: basicInfo['address'] ?? '',
                  roles: roles,
                  rawProfileData: response['data'], // Store the raw profile data for later use
                );

                await localDataSource.cacheUserProfile(user);
                _logProfileLoaded(user);
                _updateCache(user);
                return user;
              }
            }

            // Fallback to old format
            final user = User.fromJson(response);

            // Cập nhật cache
            await localDataSource.cacheUserProfile(user);
            _logProfileLoaded(user);
            _updateCache(user);
            return user;
          } catch (apiError) {
            // Nếu lỗi API là 404 hoặc endpoint không tồn tại, có thể là do API URL không đúng
            if (apiError.toString().contains('Không tìm thấy tài nguyên')) {
              AppLogger.e(_tag,
                  'Sai endpoint hồ sơ, kiểm tra lại ${ApiConstants.profile}',
                  error: apiError);

              // Thử lấy dữ liệu từ cache
              final cachedUser = await localDataSource.getCachedUserProfile();
              if (cachedUser != null) {
                _logCacheFallback(cachedUser, 'API trả về 404');
                return cachedUser;
              }
            }

            rethrow;
          }
        } on UnauthorizedException catch (e) {
          // Thử dùng dữ liệu cache nếu token không hợp lệ
          final cachedUser = await localDataSource.getCachedUserProfile();
          if (cachedUser != null) {
            _logCacheFallback(cachedUser, 'token bị từ chối (${e.message})');
            return cachedUser;
          }

          // Xóa token không hợp lệ
          await localDataSource.deleteToken();
          AppLogger.w(_tag,
              'Token bị từ chối và không có cache nên đã xóa token · ${e.message}');

          throw UnauthorizedException('Token xác thực không hợp lệ hoặc đã hết hạn');
        } catch (e) {
          // Với các lỗi khác, thử dùng dữ liệu đã lưu trong cache
          final cachedUser = await localDataSource.getCachedUserProfile();
          if (cachedUser != null) {
            _logCacheFallback(cachedUser, 'lỗi khi gọi API: $e');
            return cachedUser;
          }
          throw Exception('Lấy thông tin người dùng thất bại: ${e.toString()}');
        }
      } else {
        // Không có kết nối, sử dụng dữ liệu đã lưu trong cache
        final cachedUser = await localDataSource.getCachedUserProfile();
        if (cachedUser != null) {
          _logCacheFallback(cachedUser, 'không có kết nối mạng');
          return cachedUser;
        }
        throw Exception('Không có kết nối mạng và không có dữ liệu đã lưu');
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        // Nhánh bắt lỗi bên trong đã log lý do cụ thể rồi, không lặp lại ở đây.
        rethrow;
      }
      AppLogger.e(_tag, 'Không lấy được hồ sơ người dùng', error: e);
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
        AppLogger.w(_tag, 'Không cập nhật được hồ sơ: mất kết nối mạng');
        throw Exception('Không có kết nối mạng');
      }

      final token = await localDataSource.getToken();
      if (token == null) {
        AppLogger.w(_tag, 'Không cập nhật được hồ sơ: chưa đăng nhập');
        throw UnauthorizedException('Người dùng chưa đăng nhập');
      }

      // Tạo body request với các thông tin cần cập nhật
      final Map<String, dynamic> requestBody = {};
      if (fullName != null) requestBody['full_name'] = fullName;
      if (email != null) requestBody['email'] = email;
      if (phone != null) requestBody['phone'] = phone;
      if (address != null) requestBody['address'] = address;

      AppLogger.d(_tag, 'Cập nhật hồ sơ · ${requestBody.keys.join(', ')}');
      final userData = await remoteDataSource.updateUserProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
      );

      final updatedUser = User.fromJson(userData);

      // Cập nhật cache
      await localDataSource.cacheUserProfile(updatedUser);
      AppLogger.i(_tag, 'Đã cập nhật hồ sơ: ${updatedUser.fullName}');

      return updatedUser;
    } catch (e) {
      AppLogger.e(_tag, 'Cập nhật hồ sơ thất bại', error: e);
      if (e is UnauthorizedException) rethrow;
      throw Exception('Cập nhật thông tin người dùng thất bại: ${e.toString()}');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      if (!await networkInfo.isConnected) {
        AppLogger.w(_tag, 'Không đổi được mật khẩu: mất kết nối mạng');
        throw Exception('Không có kết nối mạng');
      }

      final token = await localDataSource.getToken();
      if (token == null) {
        AppLogger.w(_tag, 'Không đổi được mật khẩu: chưa đăng nhập');
        throw UnauthorizedException('Người dùng chưa đăng nhập');
      }

await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      AppLogger.i(_tag, 'Đã đổi mật khẩu thành công');
    } catch (e) {
      AppLogger.e(_tag, 'Đổi mật khẩu thất bại', error: e);
      if (e is UnauthorizedException) rethrow;
      throw Exception('Thay đổi mật khẩu thất bại: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      if (!await networkInfo.isConnected) {
        AppLogger.w(_tag, 'Không gửi được yêu cầu đặt lại mật khẩu: mất kết nối mạng');
        throw Exception('Không có kết nối mạng');
      }

await remoteDataSource.forgotPassword(email);
      AppLogger.i(_tag, 'Đã gửi yêu cầu đặt lại mật khẩu cho $email');
    } catch (e) {
      AppLogger.e(_tag, 'Yêu cầu đặt lại mật khẩu thất bại', error: e);
      throw Exception('Yêu cầu đặt lại mật khẩu thất bại: ${e.toString()}');
    }
  }

  // Quản lý phiên
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getToken();
    AppLogger.d(_tag,
        'Trạng thái đăng nhập: ${token != null ? "đã đăng nhập" : "chưa đăng nhập"}');
    return token != null;
  }

  // Helper method to update internal cache
  void _updateCache(User user) {
    _cachedUser = user;
    _lastFetchTime = DateTime.now();
  }

  /// Một dòng duy nhất cho mọi lần lấy được hồ sơ từ API.
  void _logProfileLoaded(User user) {
    AppLogger.i(_tag,
        'Hồ sơ: ${user.fullName} (id=${user.id}, roles=${user.roles ?? const []})');
  }

  /// Một dòng duy nhất cho mọi lần phải lùi về hồ sơ trong cache, kèm lý do —
  /// trước đây bốn nhánh khác nhau in ra cùng một câu nên không biết vì sao.
  void _logCacheFallback(User user, String reason) {
    AppLogger.w(_tag, 'Dùng hồ sơ trong cache: ${user.fullName} · $reason');
  }
}