import '../models/recycling_record_model.dart';
import '../models/waste_type_model.dart';
import '../core/network/network_info.dart';
import '../data/datasources/local_data_source.dart';
import '../data/datasources/remote_data_source.dart';
import '../models/recycling_statistics_model.dart';
import 'waste_type_repository.dart';
import 'dart:developer' as developer;

class RecyclingProgressRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final WasteTypeRepository wasteTypeRepository;

  RecyclingProgressRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.wasteTypeRepository,
  });

  /// Lịch sử tái chế của người dùng.
  ///
  /// Backend hiện chỉ phơi ra `RecyclingProcess` (quy trình xử lý phía đơn vị
  /// tái chế) và các endpoint thống kê, chưa có endpoint nào trả về đúng hình
  /// dạng `RecyclingRecord` (bản ghi từng lần người dùng nộp rác). Suy diễn ra
  /// một phép ánh xạ ở đây sẽ là đoán mò, nên tạm trả danh sách rỗng — màn hình
  /// đã xử lý sẵn trường hợp này bằng thông báo "Không có bản ghi tái chế nào".
  ///
  /// Khi backend bổ sung endpoint, thay thân hàm bằng lời gọi tương ứng.
  Future<List<RecyclingRecord>> getRecyclingRecords() async {
    return const [];
  }

  /// Danh sách loại rác dùng cho bộ lọc trên màn hình tiến trình tái chế.
  Future<List<WasteType>> getWasteTypes() async {
    try {
      return await wasteTypeRepository.getWasteTypes();
    } catch (e) {
      developer.log('Lỗi khi lấy danh sách loại rác: $e', error: e);
      throw Exception('Không thể lấy danh sách loại rác: $e');
    }
  }
  
  // Fetch recycling statistics from the API
  Future<RecyclingStatisticsData> getRecyclingStatistics({
    required String fromDate,
    required String toDate,
    String? wasteTypeId,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        throw Exception('Không có kết nối internet');
      }
      
      developer.log('Đang lấy thống kê tái chế từ API...');
      return await remoteDataSource.getRecyclingStatistics(
        fromDate: fromDate,
        toDate: toDate,
        wasteTypeId: wasteTypeId,
      );
    } catch (e) {
      developer.log('Lỗi khi lấy thống kê tái chế: $e');
      throw Exception('Không thể lấy thống kê tái chế: $e');
    }
  }

  /// Lọc bản ghi theo khoảng ngày, bao gồm cả hai đầu mút.
  ///
  /// Trước đây đầu khoảng dùng `isAfter(startDate)` nên bản ghi rơi đúng vào
  /// mốc bắt đầu bị loại, trong khi đầu kia lại bao trọn cả ngày kết thúc.
  /// Sự bất đối xứng đó khiến người dùng chọn "từ ngày X" mà mất bản ghi lúc
  /// 00:00 ngày X. Nay cả hai đầu đều được tính vào.
  List<RecyclingRecord> filterByDateRange(
    List<RecyclingRecord> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    return records.where((record) {
      return !record.date.isBefore(startDate) &&
          record.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
  
  // Filter records by waste type
  List<RecyclingRecord> filterByWasteType(
    List<RecyclingRecord> records, 
    String wasteTypeId
  ) {
    return records.where((record) => record.wasteTypeId == wasteTypeId).toList();
  }
  
  // Calculate statistics
  Map<String, double> calculateWasteTypeQuantities(List<RecyclingRecord> records) {
    final Map<String, double> quantities = {};
    
    for (var record in records) {
      if (quantities.containsKey(record.wasteTypeName)) {
        quantities[record.wasteTypeName] = 
            quantities[record.wasteTypeName]! + record.weight;
      } else {
        quantities[record.wasteTypeName] = record.weight;
      }
    }
    
    return quantities;
  }
  
  double calculateTotalWeight(List<RecyclingRecord> records) {
    return records.fold(0, (total, record) => total + record.weight);
  }
} 