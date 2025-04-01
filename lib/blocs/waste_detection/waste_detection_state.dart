import 'dart:io';
import '../../models/waste_detection_model.dart';
import '../../models/transaction_model.dart';

abstract class WasteDetectionState {
  const WasteDetectionState();
}

class WasteDetectionInitial extends WasteDetectionState {
  const WasteDetectionInitial();
}

class CameraInitializing extends WasteDetectionState {
  const CameraInitializing();
}

class CameraReady extends WasteDetectionState {
  const CameraReady();
}

class CameraError extends WasteDetectionState {
  final String errorMessage;
  
  const CameraError({required this.errorMessage});
}

class ImageCaptured extends WasteDetectionState {
  final File imageFile;
  
  const ImageCaptured({required this.imageFile});
}

class DetectingWaste extends WasteDetectionState {
  final File imageFile;
  
  const DetectingWaste({required this.imageFile});
}

class WasteDetected extends WasteDetectionState {
  final WasteDetectionResult result;
  final File imageFile;
  
  const WasteDetected({
    required this.result,
    required this.imageFile,
  });
}

class DetectionError extends WasteDetectionState {
  final String errorMessage;
  final File? imageFile;
  
  const DetectionError({
    required this.errorMessage,
    this.imageFile,
  });
}

class SavingResult extends WasteDetectionState {
  final WasteDetectionResult result;
  final File imageFile;
  final double quantity;
  final String unit;
  
  const SavingResult({
    required this.result,
    required this.imageFile,
    required this.quantity,
    required this.unit,
  });
}

class ResultSaved extends WasteDetectionState {
  final Transaction transaction;
  
  const ResultSaved({required this.transaction});
}

class SaveError extends WasteDetectionState {
  final String errorMessage;
  
  const SaveError({required this.errorMessage});
} 