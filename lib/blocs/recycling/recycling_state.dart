import 'package:equatable/equatable.dart';
import '../../models/recycling_process_model.dart';
import '../../models/recycling_report_model.dart';

abstract class RecyclingState extends Equatable {
  const RecyclingState();

  @override
  List<Object?> get props => [];
}

// Trạng thái ban đầu
class RecyclingInitial extends RecyclingState {}

// Trạng thái đang tải
class RecyclingLoading extends RecyclingState {}

// Trạng thái tải danh sách thành công
class RecyclingProcessesLoaded extends RecyclingState {
  final List<RecyclingProcess> processes;
  final int page;
  final int totalPages;
  final int total;

  const RecyclingProcessesLoaded({
    required this.processes,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  @override
  List<Object?> get props => [processes, page, totalPages, total];
}

// Trạng thái tải chi tiết thành công
class RecyclingProcessLoaded extends RecyclingState {
  final RecyclingProcess process;

  const RecyclingProcessLoaded({required this.process});

  @override
  List<Object?> get props => [process];
}

// Trạng thái tạo mới thành công
class RecyclingProcessCreated extends RecyclingState {
  final RecyclingProcess process;

  const RecyclingProcessCreated({required this.process});

  @override
  List<Object?> get props => [process];
}

// Trạng thái cập nhật thành công
class RecyclingProcessUpdated extends RecyclingState {
  final RecyclingProcess process;

  const RecyclingProcessUpdated({required this.process});

  @override
  List<Object?> get props => [process];
}

// Trạng thái tải báo cáo thành công
class RecyclingReportLoaded extends RecyclingState {
  final RecyclingReport report;

  const RecyclingReportLoaded({required this.report});

  @override
  List<Object?> get props => [report];
}

// Trạng thái tải thống kê thành công
class RecyclingStatisticsLoaded extends RecyclingState {
  final Map<String, dynamic> statistics;

  const RecyclingStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

// Trạng thái tải danh sách theo người dùng thành công
class UserRecyclingProcessesLoaded extends RecyclingState {
  final List<RecyclingProcess> processes;
  final String userId;

  const UserRecyclingProcessesLoaded({
    required this.processes,
    required this.userId,
  });

  @override
  List<Object?> get props => [processes, userId];
}

// Trạng thái gửi thông báo thành công
class RecyclingNotificationSent extends RecyclingState {
  final String id;
  final String message;

  const RecyclingNotificationSent({
    required this.id,
    required this.message,
  });

  @override
  List<Object?> get props => [id, message];
}

// Trạng thái lỗi
class RecyclingError extends RecyclingState {
  final String message;

  const RecyclingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class RecyclingProcessDeleted extends RecyclingState {}
