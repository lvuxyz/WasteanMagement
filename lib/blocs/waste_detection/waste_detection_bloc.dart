import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../repositories/waste_detection_repository.dart';
import '../../repositories/dashboard_repository.dart';
import '../../models/transaction_model.dart';
import 'waste_detection_event.dart';
import 'waste_detection_state.dart';

class WasteDetectionBloc extends Bloc<WasteDetectionEvent, WasteDetectionState> {
  final WasteDetectionRepository detectionRepository;
  final DashboardRepository dashboardRepository;
  final ImagePicker imagePicker = ImagePicker();

  WasteDetectionBloc({
    required this.detectionRepository,
    required this.dashboardRepository,
  }) : super(const WasteDetectionInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<CaptureImage>(_onCaptureImage);
    on<SelectImage>(_onSelectImage);
    on<DetectWaste>(_onDetectWaste);
    on<SaveDetectionResult>(_onSaveDetectionResult);
    on<ResetDetection>(_onResetDetection);
  }

  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<WasteDetectionState> emit,
  ) async {
    emit(const CameraInitializing());
    
    try {
      // Trong thực tế, đây sẽ là code khởi tạo camera
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const CameraReady());
    } catch (e) {
      emit(CameraError(errorMessage: e.toString()));
    }
  }

  Future<void> _onCaptureImage(
    CaptureImage event,
    Emitter<WasteDetectionState> emit,
  ) async {
    try {
      final XFile? imageFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );
      
      if (imageFile != null) {
        final file = File(imageFile.path);
        emit(ImageCaptured(imageFile: file));
        add(DetectWaste(imageFile: file));
      }
    } catch (e) {
      emit(CameraError(errorMessage: 'Không thể chụp ảnh: ${e.toString()}'));
    }
  }
  
  Future<void> _onSelectImage(
    SelectImage event,
    Emitter<WasteDetectionState> emit,
  ) async {
    emit(ImageCaptured(imageFile: event.imageFile));
    add(DetectWaste(imageFile: event.imageFile));
  }

  Future<void> _onDetectWaste(
    DetectWaste event,
    Emitter<WasteDetectionState> emit,
  ) async {
    emit(DetectingWaste(imageFile: event.imageFile));
    
    try {
      final result = await detectionRepository.detectWasteFromImage(event.imageFile);
      if (result.success) {
        emit(WasteDetected(result: result, imageFile: event.imageFile));
      } else {
        emit(DetectionError(
          errorMessage: result.errorMessage ?? 'Không thể nhận diện rác',
          imageFile: event.imageFile,
        ));
      }
    } catch (e) {
      emit(DetectionError(
        errorMessage: 'Lỗi khi phân tích: ${e.toString()}',
        imageFile: event.imageFile,
      ));
    }
  }

  Future<void> _onSaveDetectionResult(
    SaveDetectionResult event,
    Emitter<WasteDetectionState> emit,
  ) async {
    final currentState = state;
    if (currentState is WasteDetected) {
      try {
        emit(SavingResult(
          result: currentState.result,
          imageFile: currentState.imageFile,
          quantity: event.quantity,
          unit: event.unit,
        ));
        
        // Giả lập lưu kết quả
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Tạo transaction mới
        final transaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch,
          userId: event.userId,
          collectionPointId: 1, // Giả định điểm thu gom mặc định
          wasteTypeId: currentState.result.detectedWaste!.id,
          quantity: event.quantity,
          unit: event.unit,
          transactionDate: DateTime.now(),
          status: 'verified',
          proofImageUrl: currentState.imageFile.path,
          wasteName: currentState.result.detectedWaste!.name,
        );
        
        emit(ResultSaved(transaction: transaction));
      } catch (e) {
        emit(SaveError(errorMessage: 'Không thể lưu kết quả: ${e.toString()}'));
      }
    }
  }

  void _onResetDetection(
    ResetDetection event,
    Emitter<WasteDetectionState> emit,
  ) {
    emit(const CameraReady());
  }
} 