import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../core/api/api_constants.dart';
import '../services/auth_service.dart';

class UploadResult {
  final bool success;
  final String? imageUrl;
  final String message;

  UploadResult({
    required this.success,
    this.imageUrl,
    required this.message,
  });
}

class UploadService {
  final AuthService _authService = AuthService();

  Future<UploadResult> uploadImage(File imageFile) async {
    try {
      // Get the token
      final token = await _authService.getToken();
      if (token == null) {
        return UploadResult(
          success: false,
          message: 'Không tìm thấy token xác thực',
        );
      }

      // Get file extension
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final mimeType = _getMimeType(fileExtension);

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/upload'),
      );

      // Add authorization header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add file to request
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType(
          _getMediaType(fileExtension),
          fileExtension,
        ),
      ));

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          return UploadResult(
            success: true,
            imageUrl: data['file_url'],
            message: 'Tải lên thành công',
          );
        } else {
          return UploadResult(
            success: false,
            message: data['message'] ?? 'Tải lên thất bại',
          );
        }
      } else {
        return UploadResult(
          success: false,
          message: 'Lỗi server: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      return UploadResult(
        success: false,
        message: 'Lỗi tải lên: $e',
      );
    }
  }

  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  String _getMediaType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      default:
        return 'application';
    }
  }
} 