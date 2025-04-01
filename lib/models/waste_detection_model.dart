import '../models/waste_type_model.dart';

class WasteDetectionResult {
  final bool success;
  final WasteType? detectedWaste;
  final String? imageUrl;
  final String? errorMessage;
  final double? confidence;
  final List<WasteType>? alternatives;
  final Map<String, dynamic>? recyclableInfo;

  WasteDetectionResult({
    required this.success,
    this.detectedWaste,
    this.imageUrl,
    this.errorMessage,
    this.confidence,
    this.alternatives,
    this.recyclableInfo,
  });

  // Phân loại thành công nếu phát hiện rác với độ tin cậy > 70%
  bool get isReliableDetection => success && confidence != null && confidence! > 70.0;

  // Hướng dẫn xử lý rác
  String get handlingInstructions => 
    detectedWaste?.handlingInstructions ?? 'Không có hướng dẫn';

  // Kiểm tra xem rác có thể tái chế không
  bool get isRecyclable => detectedWaste?.recyclable ?? false;

  factory WasteDetectionResult.fromJson(Map<String, dynamic> json) {
    return WasteDetectionResult(
      success: json['success'] ?? false,
      detectedWaste: json['detected_waste'] != null 
        ? WasteType.fromJson(json['detected_waste']) 
        : null,
      imageUrl: json['image_url'],
      errorMessage: json['error_message'],
      confidence: json['confidence'] != null 
        ? (json['confidence'] as num).toDouble() 
        : null,
      alternatives: (json['alternatives'] as List<dynamic>?)
        ?.map((alt) => WasteType.fromJson(alt))
        .toList(),
      recyclableInfo: json['recyclable_info'],
    );
  }

  factory WasteDetectionResult.error(String message) {
    return WasteDetectionResult(
      success: false,
      errorMessage: message,
    );
  }
} 