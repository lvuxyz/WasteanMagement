import 'dart:io';

abstract class WasteDetectionEvent {
  const WasteDetectionEvent();
}

class InitializeCamera extends WasteDetectionEvent {
  const InitializeCamera();
}

class CaptureImage extends WasteDetectionEvent {
  const CaptureImage();
}

class SelectImage extends WasteDetectionEvent {
  final File imageFile;
  
  const SelectImage({required this.imageFile});
}

class DetectWaste extends WasteDetectionEvent {
  final File imageFile;
  
  const DetectWaste({required this.imageFile});
}

class SaveDetectionResult extends WasteDetectionEvent {
  final double quantity;
  final String unit;
  final int userId;
  
  const SaveDetectionResult({
    required this.quantity,
    required this.unit,
    required this.userId,
  });
}

class ResetDetection extends WasteDetectionEvent {
  const ResetDetection();
} 