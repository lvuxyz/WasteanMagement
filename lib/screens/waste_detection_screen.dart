import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../blocs/waste_detection/waste_detection_bloc.dart';
import '../blocs/waste_detection/waste_detection_event.dart';
import '../blocs/waste_detection/waste_detection_state.dart';
import '../repositories/waste_detection_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../widgets/waste_detection/camera_preview_widget.dart';
import '../widgets/waste_detection/detection_result_card.dart';
import '../widgets/waste_detection/quantity_input_dialog.dart';
import '../utils/app_colors.dart';

class WasteDetectionScreen extends StatelessWidget {
  const WasteDetectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WasteDetectionBloc(
        detectionRepository: WasteDetectionRepository(),
        dashboardRepository: DashboardRepository(),
      )..add(const InitializeCamera()),
      child: const WasteDetectionView(),
    );
  }
}

class WasteDetectionView extends StatelessWidget {
  const WasteDetectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WasteDetectionBloc, WasteDetectionState>(
      listener: (context, state) {
        if (state is ResultSaved) {
          // Hiển thị thông báo thành công và quay về trang trước
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lưu kết quả thành công!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          
          // Delay 1 giây trước khi quay về
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context);
          });
        } else if (state is SaveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      },
      builder: (context, state) {
        // Màn hình camera
        if (state is CameraInitializing) {
          return _buildLoadingScreen('Đang khởi tạo camera...');
        } else if (state is CameraReady) {
          return Scaffold(
            body: CameraPreviewWidget(
              onCapture: () => context.read<WasteDetectionBloc>().add(const CaptureImage()),
              onGallerySelect: () => _selectImageFromGallery(context),
            ),
          );
        } else if (state is CameraError) {
          return _buildErrorScreen(state.errorMessage);
        }
        
        // Màn hình phân tích
        else if (state is DetectingWaste) {
          return _buildLoadingScreen('Đang phân tích rác...');
        } else if (state is WasteDetected) {
          return _buildDetectionResultScreen(context, state);
        } else if (state is DetectionError) {
          return _buildDetectionErrorScreen(context, state);
        }
        
        // Màn hình lưu kết quả
        else if (state is SavingResult) {
          return _buildLoadingScreen('Đang lưu kết quả...');
        }
        
        // Trạng thái mặc định - hiển thị loading
        return _buildLoadingScreen('Khởi tạo...');
      },
    );
  }
  
  // Chọn ảnh từ thư viện
  Future<void> _selectImageFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null && context.mounted) {
      final file = File(image.path);
      context.read<WasteDetectionBloc>().add(SelectImage(imageFile: file));
    }
  }
  
  // Màn hình loading
  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
  
  // Màn hình lỗi
  Widget _buildErrorScreen(String errorMessage) {
    return Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('AI Quét Rác'),
          backgroundColor: AppColors.primaryGreen,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.errorRed,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Đã xảy ra lỗi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Màn hình kết quả nhận diện
  Widget _buildDetectionResultScreen(BuildContext context, WasteDetected state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả nhận diện'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hiển thị ảnh đã chụp/chọn
            if (state.imageFile.existsSync())
              SizedBox(
                height: 250,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      state.imageFile,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                    if (state.result.detectedWaste != null)
                      Center(
                        child: Text(
                          state.result.detectedWaste!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            
            // Card kết quả nhận diện
            DetectionResultCard(
              result: state.result,
              onSave: () {
                if (state.result.detectedWaste != null) {
                  // Hiển thị hộp thoại nhập khối lượng
                  showDialog(
                    context: context,
                    builder: (context) => QuantityInputDialog(
                      wasteTypeName: state.result.detectedWaste!.name,
                      onSave: (quantity, unit) {
                        BlocProvider.of<WasteDetectionBloc>(context).add(
                          SaveDetectionResult(
                            quantity: quantity,
                            unit: unit,
                            userId: 1, // Giả định user hiện tại có ID = 1
                          ),
                        );
                      },
                    ),
                  );
                }
              },
              onRetry: () {
                // Quay lại chế độ camera
                context.read<WasteDetectionBloc>().add(const ResetDetection());
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Màn hình lỗi nhận diện
  Widget _buildDetectionErrorScreen(BuildContext context, DetectionError state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Không thể nhận diện'),
        backgroundColor: AppColors.errorRed,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hiển thị ảnh đã chụp/chọn
          if (state.imageFile != null && state.imageFile!.existsSync())
            SizedBox(
              height: 250,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    state.imageFile!,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ],
              ),
            ),
          
          // Thông báo lỗi
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Không thể nhận diện rác',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Vui lòng thử lại với một bức ảnh khác và đảm bảo rằng:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTipItem('Rác được đặt ở trung tâm khung hình'),
                _buildTipItem('Ánh sáng đủ sáng để nhìn rõ vật thể'),
                _buildTipItem('Vật thể không bị che khuất'),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondaryText,
                        side: BorderSide(color: AppColors.disabledGrey),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<WasteDetectionBloc>().add(const ResetDetection());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget mẹo nhận diện
  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.primaryGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 