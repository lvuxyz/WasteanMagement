import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:wasteanmagement/core/api/api_client.dart';
import 'package:wasteanmagement/core/network/network_info.dart';
import 'package:wasteanmagement/data/datasources/local_data_source.dart';
import 'package:wasteanmagement/data/datasources/remote_data_source.dart';
import 'package:wasteanmagement/models/recycling_record_model.dart';
import 'package:wasteanmagement/repositories/recycling_progress_repository.dart';
import 'package:wasteanmagement/repositories/waste_type_repository.dart';
import 'package:wasteanmagement/utils/secure_storage.dart';

class _FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

RecyclingRecord _record({
  required String id,
  required String wasteTypeId,
  required String wasteTypeName,
  required double weight,
  required DateTime date,
}) {
  return RecyclingRecord(
    id: id,
    wasteTypeId: wasteTypeId,
    wasteTypeName: wasteTypeName,
    wasteTypeCategory: 'recyclable',
    weight: weight,
    collectionPointId: 'cp-1',
    collectionPointName: 'Điểm thu gom số 1',
    date: date,
    userId: 'user-1',
    isVerified: true,
  );
}

void main() {
  late RecyclingProgressRepository repository;

  setUp(() {
    final apiClient = ApiClient(
      client: http.Client(),
      secureStorage: SecureStorage(),
    );
    repository = RecyclingProgressRepository(
      remoteDataSource: RemoteDataSource(apiClient: apiClient),
      wasteTypeRepository: WasteTypeRepository(apiClient: apiClient),
      localDataSource: LocalDataSource(),
      networkInfo: _FakeNetworkInfo(),
    );
  });

  group('filterByDateRange', () {
    final records = [
      _record(
        id: 'r1',
        wasteTypeId: 'wt-1',
        wasteTypeName: 'Nhựa',
        weight: 1.0,
        date: DateTime(2026, 1, 1),
      ),
      _record(
        id: 'r2',
        wasteTypeId: 'wt-2',
        wasteTypeName: 'Giấy',
        weight: 2.0,
        date: DateTime(2026, 1, 15, 8, 30),
      ),
      _record(
        id: 'r3',
        wasteTypeId: 'wt-1',
        wasteTypeName: 'Nhựa',
        weight: 3.0,
        date: DateTime(2026, 1, 31, 23, 59),
      ),
      _record(
        id: 'r4',
        wasteTypeId: 'wt-1',
        wasteTypeName: 'Nhựa',
        weight: 4.0,
        date: DateTime(2026, 2, 5),
      ),
    ];

    test('giữ bản ghi rơi đúng vào mốc bắt đầu', () {
      final result = repository.filterByDateRange(
        records,
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 31),
      );

      expect(result.map((r) => r.id), contains('r1'));
    });

    test('bao trọn ngày kết thúc, kể cả bản ghi lúc 23:59', () {
      final result = repository.filterByDateRange(
        records,
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 31),
      );

      expect(result.map((r) => r.id), containsAll(['r1', 'r2', 'r3']));
    });

    test('loại bản ghi nằm ngoài khoảng', () {
      final result = repository.filterByDateRange(
        records,
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 31),
      );

      expect(result.map((r) => r.id), isNot(contains('r4')));
      expect(result, hasLength(3));
    });

    test('trả danh sách rỗng khi khoảng ngày không chứa bản ghi nào', () {
      final result = repository.filterByDateRange(
        records,
        DateTime(2025, 1, 1),
        DateTime(2025, 12, 31),
      );

      expect(result, isEmpty);
    });
  });

  group('filterByWasteType', () {
    final records = [
      _record(
        id: 'r1',
        wasteTypeId: 'wt-1',
        wasteTypeName: 'Nhựa',
        weight: 1.0,
        date: DateTime(2026, 1, 1),
      ),
      _record(
        id: 'r2',
        wasteTypeId: 'wt-2',
        wasteTypeName: 'Giấy',
        weight: 2.0,
        date: DateTime(2026, 1, 2),
      ),
    ];

    test('chỉ giữ bản ghi đúng loại rác', () {
      final result = repository.filterByWasteType(records, 'wt-1');

      expect(result, hasLength(1));
      expect(result.single.id, 'r1');
    });

    test('trả rỗng khi không có loại rác khớp', () {
      expect(repository.filterByWasteType(records, 'wt-99'), isEmpty);
    });
  });

  group('calculateWasteTypeQuantities', () {
    test('cộng dồn khối lượng theo tên loại rác', () {
      final records = [
        _record(
          id: 'r1',
          wasteTypeId: 'wt-1',
          wasteTypeName: 'Nhựa',
          weight: 1.5,
          date: DateTime(2026, 1, 1),
        ),
        _record(
          id: 'r2',
          wasteTypeId: 'wt-1',
          wasteTypeName: 'Nhựa',
          weight: 2.5,
          date: DateTime(2026, 1, 2),
        ),
        _record(
          id: 'r3',
          wasteTypeId: 'wt-2',
          wasteTypeName: 'Giấy',
          weight: 3.0,
          date: DateTime(2026, 1, 3),
        ),
      ];

      expect(
        repository.calculateWasteTypeQuantities(records),
        {'Nhựa': 4.0, 'Giấy': 3.0},
      );
    });

    test('trả map rỗng khi không có bản ghi', () {
      expect(repository.calculateWasteTypeQuantities([]), isEmpty);
    });
  });

  group('calculateTotalWeight', () {
    test('cộng tổng khối lượng mọi bản ghi', () {
      final records = [
        _record(
          id: 'r1',
          wasteTypeId: 'wt-1',
          wasteTypeName: 'Nhựa',
          weight: 1.5,
          date: DateTime(2026, 1, 1),
        ),
        _record(
          id: 'r2',
          wasteTypeId: 'wt-2',
          wasteTypeName: 'Giấy',
          weight: 2.25,
          date: DateTime(2026, 1, 2),
        ),
      ];

      expect(repository.calculateTotalWeight(records), 3.75);
    });

    test('trả 0 khi danh sách rỗng', () {
      expect(repository.calculateTotalWeight([]), 0);
    });
  });
}
