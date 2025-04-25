import 'package:flutter/material.dart';
import '../models/waste_type_model.dart';

class WasteTypeRepository {
  // Trong thực tế, dữ liệu này sẽ được lấy từ API hoặc cơ sở dữ liệu
  // Nhưng để đơn giản, chúng ta sẽ sử dụng dữ liệu mẫu
  Future<List<WasteType>> getWasteTypes() async {
    // Giả lập độ trễ khi tải dữ liệu từ server
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      WasteType(
        id: 1,
        name: 'Nhựa tái chế',
        category: 'Tái chế',
        description: 'Chai, lọ, hộp nhựa đã qua sử dụng',
        icon: Icons.local_drink_outlined,
        color: Colors.blue,
        recyclingMethod: 'Rửa sạch, làm khô và nén lại trước khi mang đi tái chế.',
        examples: ['Chai nước, Chai dầu gội', 'Hộp đựng thực phẩm', 'Túi nilon sạch'],
        buyingPrice: 5000,
        unit: 'kg',
        recentPoints: 'Tái chế 1kg nhựa = 5 điểm',
      ),
      WasteType(
        id: 2,
        name: 'Giấy, bìa carton',
        category: 'Tái chế',
        description: 'Sách báo, hộp giấy, bìa carton',
        icon: Icons.description_outlined,
        color: Colors.amber,
        recyclingMethod: 'Tháo bỏ băng keo, ghim, giữ khô ráo và xếp gọn.',
        examples: ['Giấy in, Báo/Tạp chí', 'Hộp các-tông', 'Sách vở cũ'],
        buyingPrice: 3000,
        unit: 'kg',
        recentPoints: 'Tái chế 1kg giấy = 3 điểm',
      ),
      WasteType(
        id: 3,
        name: 'Kim loại',
        category: 'Tái chế',
        description: 'Vỏ lon, đồ kim loại cũ',
        icon: Icons.settings_outlined,
        color: Colors.grey,
        recyclingMethod: 'Rửa sạch, làm khô và nén lại nếu có thể.',
        examples: ['Lon nước ngọt', 'Đồ hộp', 'Vật dụng kim loại nhỏ'],
        buyingPrice: 7000,
        unit: 'kg',
        recentPoints: 'Tái chế 1kg kim loại = 7 điểm',
      ),
      WasteType(
        id: 4,
        name: 'Kính, thủy tinh',
        category: 'Tái chế',
        description: 'Chai lọ thủy tinh, đồ thủy tinh vỡ',
        icon: Icons.wine_bar_outlined,
        color: Colors.lightBlue,
        recyclingMethod: 'Rửa sạch, tháo bỏ nắp kim loại và nhãn giấy.',
        examples: ['Chai rượu, bia', 'Lọ đựng gia vị', 'Chai mỹ phẩm'],
        buyingPrice: 2000,
        unit: 'kg',
        recentPoints: 'Tái chế 1kg thủy tinh = 2 điểm',
      ),
      WasteType(
        id: 5,
        name: 'Rác thực phẩm',
        category: 'Hữu cơ',
        description: 'Thức ăn thừa, vỏ trái cây, rau củ',
        icon: Icons.compost_outlined,
        color: Colors.green,
        recyclingMethod: 'Có thể ủ làm phân compost hoặc thu gom riêng.',
        examples: ['Vỏ trái cây', 'Thức ăn thừa', 'Bã cà phê'],
        buyingPrice: 0,
        unit: 'kg',
        recentPoints: 'Tái chế 1kg rác hữu cơ = 1 điểm',
      ),
      WasteType(
        id: 6,
        name: 'Pin, ắc quy',
        category: 'Nguy hại',
        description: 'Pin các loại, ắc quy điện thoại/máy tính',
        icon: Icons.battery_alert_outlined,
        color: Colors.red,
        recyclingMethod: 'Cần thu gom riêng, không vứt lẫn với rác thông thường.',
        examples: ['Pin alkaline', 'Pin sạc', 'Ắc quy điện thoại'],
        buyingPrice: 0,
        unit: 'kg',
        recentPoints: 'Tái chế 1kg pin = 10 điểm',
      ),
      WasteType(
        id: 7,
        name: 'Thiết bị điện tử',
        category: 'Nguy hại',
        description: 'Điện thoại cũ, linh kiện máy tính, thiết bị điện',
        icon: Icons.smartphone_outlined,
        color: Colors.purple,
        recyclingMethod: 'Nên mang đến các điểm thu mua chuyên dụng.',
        examples: ['Điện thoại cũ', 'Máy tính', 'Thiết bị điện gia dụng'],
        buyingPrice: 0,
        unit: 'kg',
        recentPoints: 'Tái chế 1kg thiết bị điện tử = 15 điểm',
      ),
      WasteType(
        id: 8,
        name: 'Vải, quần áo',
        category: 'Tái chế',
        description: 'Quần áo cũ, vải vụn, giày dép',
        icon: Icons.checkroom_outlined,
        color: Colors.orange,
        recyclingMethod: 'Giặt sạch, gấp gọn, có thể quyên góp cho người cần.',
        examples: ['Quần áo cũ', 'Vải vụn', 'Giày dép cũ'],
        buyingPrice: 2000,
        unit: 'kg',
        recentPoints: 'Tái chế 1kg vải = 2 điểm',
      ),
    ];
  }

  // Phương thức để thêm loại rác vào kế hoạch tái chế
  Future<bool> addToRecyclingPlan(int wasteTypeId) async {
    // Giả lập việc lưu thông tin xuống database hoặc gửi lên server
    await Future.delayed(const Duration(milliseconds: 500));

    // Trong thực tế, cần kiểm tra xem thao tác có thành công không
    return true;
  }
}