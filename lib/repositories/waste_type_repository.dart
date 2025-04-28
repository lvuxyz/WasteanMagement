import 'package:flutter/material.dart';
import '../models/waste_type_model.dart';
import '../models/collection_point_model.dart';

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

  // Phương thức tìm WasteType theo ID
  Future<WasteType> getWasteTypeById(int wasteTypeId) async {
    final wasteTypes = await getWasteTypes();
    final wasteType = wasteTypes.firstWhere(
      (type) => type.id == wasteTypeId,
      orElse: () => throw Exception('Không tìm thấy loại rác với ID: $wasteTypeId'),
    );
    return wasteType;
  }

  // Phương thức lấy danh sách điểm thu gom cho một loại rác
  Future<List<CollectionPoint>> getCollectionPointsForWasteType(int wasteTypeId) async {
    // Giả lập độ trễ khi tải dữ liệu từ server
    await Future.delayed(const Duration(milliseconds: 500));

    // Dữ liệu mẫu - trong thực tế sẽ lấy từ API
    return [
      CollectionPoint(
        id: '1',
        name: 'Trung tâm Tái chế Hà Nội',
        address: '123 Đường Nguyễn Trãi, Thanh Xuân, Hà Nội',
        description: 'Trung tâm tái chế lớn nhất khu vực',
        latitude: 21.007,
        longitude: 105.823,
        imageUrl: 'assets/images/collection_point1.jpg',
        phone: '0987654321',
        email: 'contact@recycling.com',
        website: 'www.recycling.com',
        isActive: true,
        createdAt: '2023-01-01',
        updatedAt: '2023-06-01',
        status: 'active',
        current_load: 45.0,
        capacity: 100.0,
        operating_hours: '08:00 - 17:00, Thứ 2 - Thứ 7',
      ),
      CollectionPoint(
        id: '2',
        name: 'Điểm thu gom Cầu Giấy',
        address: '45 Đường Cầu Giấy, Cầu Giấy, Hà Nội',
        description: 'Điểm thu gom chuyên nhựa và giấy',
        latitude: 21.031,
        longitude: 105.801,
        imageUrl: 'assets/images/collection_point2.jpg',
        phone: '0123456789',
        email: 'caugiay@recycling.com',
        website: 'www.recycling.com/caugiay',
        isActive: true,
        createdAt: '2023-02-15',
        updatedAt: '2023-05-20',
        status: 'active',
        current_load: 30.0,
        capacity: 80.0,
        operating_hours: '07:30 - 16:30, Hàng ngày',
      ),
    ];
  }

  // Phương thức lấy tất cả các điểm thu gom
  Future<List<CollectionPoint>> getAllCollectionPoints() async {
    // Giả lập độ trễ khi tải dữ liệu từ server
    await Future.delayed(const Duration(milliseconds: 500));

    // Dữ liệu mẫu - trong thực tế sẽ lấy từ API
    return [
      CollectionPoint(
        id: '1',
        name: 'Trung tâm Tái chế Hà Nội',
        address: '123 Đường Nguyễn Trãi, Thanh Xuân, Hà Nội',
        description: 'Trung tâm tái chế lớn nhất khu vực',
        latitude: 21.007,
        longitude: 105.823,
        imageUrl: 'assets/images/collection_point1.jpg',
        phone: '0987654321',
        email: 'contact@recycling.com',
        website: 'www.recycling.com',
        isActive: true,
        createdAt: '2023-01-01',
        updatedAt: '2023-06-01',
        status: 'active',
        current_load: 45.0,
        capacity: 100.0,
        operating_hours: '08:00 - 17:00, Thứ 2 - Thứ 7',
      ),
      CollectionPoint(
        id: '2',
        name: 'Điểm thu gom Cầu Giấy',
        address: '45 Đường Cầu Giấy, Cầu Giấy, Hà Nội',
        description: 'Điểm thu gom chuyên nhựa và giấy',
        latitude: 21.031,
        longitude: 105.801,
        imageUrl: 'assets/images/collection_point2.jpg',
        phone: '0123456789',
        email: 'caugiay@recycling.com',
        website: 'www.recycling.com/caugiay',
        isActive: true,
        createdAt: '2023-02-15',
        updatedAt: '2023-05-20',
        status: 'active',
        current_load: 30.0,
        capacity: 80.0,
        operating_hours: '07:30 - 16:30, Hàng ngày',
      ),
      CollectionPoint(
        id: '3',
        name: 'Điểm thu gom Thanh Xuân',
        address: '78 Đường Nguyễn Trãi, Thanh Xuân, Hà Nội',
        description: 'Điểm thu gom tất cả các loại rác tái chế',
        latitude: 21.001,
        longitude: 105.815,
        imageUrl: 'assets/images/collection_point3.jpg',
        phone: '0369852147',
        email: 'thanhxuan@recycling.com',
        website: 'www.recycling.com/thanhxuan',
        isActive: true,
        createdAt: '2023-03-10',
        updatedAt: '2023-05-15',
        status: 'active',
        current_load: 65.0,
        capacity: 120.0,
        operating_hours: '08:00 - 18:00, Thứ 2 - Thứ 6',
      ),
    ];
  }

  // Phương thức xóa loại rác
  Future<bool> deleteWasteType(int wasteTypeId) async {
    // Giả lập độ trễ khi xóa dữ liệu trên server
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trong thực tế, cần kiểm tra xem thao tác có thành công không
    return true;
  }

  // Phương thức liên kết loại rác với điểm thu gom
  Future<bool> linkCollectionPoint(int wasteTypeId, int collectionPointId) async {
    // Giả lập độ trễ khi thực hiện thao tác trên server
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trong thực tế, cần kiểm tra xem thao tác có thành công không
    return true;
  }

  // Phương thức hủy liên kết loại rác với điểm thu gom
  Future<bool> unlinkCollectionPoint(int wasteTypeId, int collectionPointId) async {
    // Giả lập độ trễ khi thực hiện thao tác trên server
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trong thực tế, cần kiểm tra xem thao tác có thành công không
    return true;
  }
  
  // Phương thức tạo loại rác mới
  Future<WasteType> createWasteType(WasteType wasteType) async {
    // Giả lập độ trễ khi tạo dữ liệu trên server
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Giả lập tạo ID mới
    final newWasteType = WasteType(
      id: DateTime.now().millisecondsSinceEpoch % 1000, // Tạo ID giả
      name: wasteType.name,
      category: wasteType.category,
      description: wasteType.description,
      icon: wasteType.icon,
      color: wasteType.color,
      recyclingMethod: wasteType.recyclingMethod,
      examples: wasteType.examples,
      buyingPrice: wasteType.buyingPrice,
      unit: wasteType.unit,
      recentPoints: wasteType.recentPoints,
    );
    
    // Trong thực tế, sẽ lưu dữ liệu này xuống database hoặc gửi đến server
    return newWasteType;
  }
  
  // Phương thức cập nhật loại rác
  Future<WasteType> updateWasteType(WasteType wasteType) async {
    // Giả lập độ trễ khi cập nhật dữ liệu trên server
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trong thực tế, sẽ cập nhật xuống database hoặc gửi đến server
    return wasteType;
  }
}