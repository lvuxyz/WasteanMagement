import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class CameraPreviewWidget extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onGallerySelect;
  
  const CameraPreviewWidget({
    Key? key,
    required this.onCapture,
    required this.onGallerySelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Màn hình camera sẽ hiển thị ở đây
        // Trong thực tế, đây sẽ là CameraPreview từ camera_flutter package
        Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Icon(
              Icons.camera_alt,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
        
        // Overlay hướng dẫn
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Đặt rác vào giữa khung hình',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Khung nhận diện
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryGreen,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        
        // Nút chụp ảnh và gallery
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nút chọn từ thư viện
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(right: 40),
                child: IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  onPressed: onGallerySelect,
                  iconSize: 32,
                ),
              ),
              
              // Nút chụp ảnh chính
              GestureDetector(
                onTap: onCapture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGreen, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Thanh tiêu đề
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Quét Rác',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} 