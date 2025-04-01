import 'dart:io';
import 'dart:async';
import '../models/waste_detection_model.dart';
import '../models/waste_type_model.dart';

class WasteDetectionRepository {
  // Trong môi trường thực tế, đây sẽ là một API call đến backend AI
  // Hiện tại chúng ta sẽ giả lập kết quả
  
  Future<WasteDetectionResult> detectWasteFromImage(File imageFile) async {
    // Giả lập độ trễ của API
    await Future.delayed(const Duration(seconds: 2));
    
    // Dữ liệu giả lập - Trong thực tế, đây sẽ là kết quả từ mô hình AI
    return WasteDetectionResult(
      success: true,
      detectedWaste: WasteType(
        id: 1,
        name: 'Nhựa',
        description: 'Chai nhựa loại 1 (PET/PETE)',
        recyclable: true,
        handlingInstructions: 'Rửa sạch, tháo nhãn và đậy, bỏ vào thùng tái chế nhựa',
        unitPrice: 5000,
        imageUrl: 'assets/images/waste_types/plastic.png',
      ),
      imageUrl: imageFile.path,
      confidence: 95.8,
      alternatives: [
        WasteType(
          id: 7,
          name: 'Nhựa mềm',
          description: 'Túi nilon, bao bì nhựa mềm',
          recyclable: false,
          handlingInstructions: 'Không tái chế được, bỏ vào thùng rác thông thường',
          unitPrice: 0,
          imageUrl: 'assets/images/waste_types/soft_plastic.png',
        ),
      ],
      recyclableInfo: {
        'can_recycle': true,
        'recycle_value': 'Cao',
        'environmental_impact': 'Giảm thiểu 80% khí thải nhà kính so với sản xuất mới',
      },
    );
  }
  
  Future<List<WasteType>> getAllWasteTypes() async {
    // Giả lập độ trễ của API
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Dữ liệu giả lập - Danh sách các loại rác
    return [
      WasteType(
        id: 1,
        name: 'Nhựa',
        description: 'Chai nhựa loại 1 (PET/PETE)',
        recyclable: true,
        handlingInstructions: 'Rửa sạch, tháo nhãn và đậy, bỏ vào thùng tái chế nhựa',
        unitPrice: 5000,
        imageUrl: 'assets/images/waste_types/plastic.png',
      ),
      WasteType(
        id: 2,
        name: 'Giấy',
        description: 'Giấy, báo, tạp chí, hộp carton',
        recyclable: true,
        handlingInstructions: 'Làm phẳng, bỏ tạp chất, đặt vào thùng tái chế giấy',
        unitPrice: 3000,
        imageUrl: 'assets/images/waste_types/paper.png',
      ),
      WasteType(
        id: 3,
        name: 'Kim loại',
        description: 'Lon nhôm, hộp thiếc, đồ kim loại',
        recyclable: true,
        handlingInstructions: 'Rửa sạch, làm bẹp lon và bỏ vào thùng tái chế kim loại',
        unitPrice: 8000,
        imageUrl: 'assets/images/waste_types/metal.png',
      ),
      WasteType(
        id: 4,
        name: 'Thủy tinh',
        description: 'Chai lọ thủy tinh',
        recyclable: true,
        handlingInstructions: 'Rửa sạch, tháo nắp, bỏ vào thùng tái chế thủy tinh',
        unitPrice: 2000,
        imageUrl: 'assets/images/waste_types/glass.png',
      ),
      WasteType(
        id: 5,
        name: 'Rác hữu cơ',
        description: 'Thức ăn thừa, rau quả, lá cây',
        recyclable: true,
        handlingInstructions: 'Bỏ vào thùng ủ phân compost hoặc thùng rác hữu cơ',
        unitPrice: 1000,
        imageUrl: 'assets/images/waste_types/organic.png',
      ),
    ];
  }
} 