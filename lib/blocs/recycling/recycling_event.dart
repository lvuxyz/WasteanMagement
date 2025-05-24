import 'package:equatable/equatable.dart';

abstract class RecyclingEvent extends Equatable {
  const RecyclingEvent();

  @override
  List<Object?> get props => [];
}

// Lấy danh sách quy trình tái chế có phân trang
class GetRecyclingProcesses extends RecyclingEvent {
  final int page;
  final int limit;
  final String? status;
  final String? wasteTypeId;
  final String? fromDate;
  final String? toDate;

  const GetRecyclingProcesses({
    this.page = 1,
    this.limit = 10,
    this.status,
    this.wasteTypeId,
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [page, limit, status, wasteTypeId, fromDate, toDate];
}

// Lấy toàn bộ danh sách quy trình tái chế
class GetAllRecyclingProcesses extends RecyclingEvent {
  const GetAllRecyclingProcesses();
}

// Lấy chi tiết quy trình tái chế
class GetRecyclingProcessDetail extends RecyclingEvent {
  final String id;

  const GetRecyclingProcessDetail(this.id);

  @override
  List<Object?> get props => [id];
}

// Tạo mới quy trình tái chế
class CreateRecyclingProcess extends RecyclingEvent {
  final String transactionId;
  final String wasteTypeId;
  final double? quantity;
  final String? notes;

  const CreateRecyclingProcess({
    required this.transactionId,
    required this.wasteTypeId,
    this.quantity,
    this.notes,
  });

  @override
  List<Object?> get props => [transactionId, wasteTypeId, quantity, notes];
}

// Cập nhật quy trình tái chế
class UpdateRecyclingProcess extends RecyclingEvent {
  final String id;
  final Map<String, dynamic> updateData;

  const UpdateRecyclingProcess({
    required this.id,
    required this.updateData,
  });

  @override
  List<Object?> get props => [id, updateData];
}

// Lấy báo cáo thống kê quy trình tái chế
class GetRecyclingReport extends RecyclingEvent {
  final String fromDate;
  final String toDate;
  final String? wasteTypeId;

  const GetRecyclingReport({
    required this.fromDate,
    required this.toDate,
    this.wasteTypeId,
  });

  @override
  List<Object?> get props => [fromDate, toDate, wasteTypeId];
}

// Lấy thống kê số liệu tái chế
class GetRecyclingStatistics extends RecyclingEvent {
  final String fromDate;
  final String toDate;
  final String? wasteTypeId;

  const GetRecyclingStatistics({
    required this.fromDate,
    required this.toDate,
    this.wasteTypeId,
  });

  @override
  List<Object?> get props => [fromDate, toDate, wasteTypeId];
}

// Lấy danh sách quy trình tái chế theo người dùng
class GetUserRecyclingProcesses extends RecyclingEvent {
  final String userId;

  const GetUserRecyclingProcesses(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Gửi thông báo cập nhật quy trình tái chế
class SendRecyclingNotification extends RecyclingEvent {
  final String id;
  final String message;

  const SendRecyclingNotification({
    required this.id,
    required this.message,
  });

  @override
  List<Object?> get props => [id, message];
}
