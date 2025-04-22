class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> data;

  ApiResponse({
    required this.statusCode,
    required this.data,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  dynamic get body => data;

  String get message => data['message'] ?? '';

  Map<String, dynamic> get errors =>
      data['errors'] is Map ? data['errors'] : {};
}