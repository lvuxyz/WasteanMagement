import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../repositories/recycling_repository.dart';
import 'recycling_event.dart';
import 'recycling_state.dart';

class RecyclingBloc extends Bloc<RecyclingEvent, RecyclingState> {
  final RecyclingRepository repository;

  RecyclingBloc({required this.repository}) : super(RecyclingInitial()) {
    on<GetRecyclingProcesses>(_onGetRecyclingProcesses);
    on<GetAllRecyclingProcesses>(_onGetAllRecyclingProcesses);
    on<GetRecyclingProcessDetail>(_onGetRecyclingProcessDetail);
    on<CreateRecyclingProcess>(_onCreateRecyclingProcess);
    on<UpdateRecyclingProcess>(_onUpdateRecyclingProcess);
    on<GetRecyclingReport>(_onGetRecyclingReport);
    on<GetRecyclingStatistics>(_onGetRecyclingStatistics);
    on<GetUserRecyclingProcesses>(_onGetUserRecyclingProcesses);
    on<SendRecyclingNotification>(_onSendRecyclingNotification);
  }

  Future<void> _onGetRecyclingProcesses(
    GetRecyclingProcesses event,
    Emitter<RecyclingState> emit,
  ) async {
    try {
      emit(RecyclingLoading());
      
      final result = await repository.getRecyclingProcesses(
        page: event.page,
        limit: event.limit,
        status: event.status,
        wasteTypeId: event.wasteTypeId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );
      
      emit(RecyclingProcessesLoaded(
        processes: result['processes'],
        total: result['total'],
        page: result['page'],
        totalPages: result['totalPages'],
      ));
    } catch (e) {
      developer.log('Lỗi khi lấy danh sách quy trình tái chế: $e', error: e);
      emit(RecyclingError(message: e.toString()));
    }
  }

  Future<void> _onGetAllRecyclingProcesses(
    GetAllRecyclingProcesses event,
    Emitter<RecyclingState> emit,
  ) async {
    try {
      emit(RecyclingLoading());
      
      final processes = await repository.getAllRecyclingProcesses();
      
      emit(RecyclingProcessesLoaded(
        processes: processes,
        total: processes.length,
        page: 1,
        totalPages: 1,
      ));
    } catch (e) {
      developer.log('Lỗi khi lấy toàn bộ quy trình tái chế: $e', error: e);
      emit(RecyclingError(message: e.toString()));
    }
  }

  Future<void> _onGetRecyclingProcessDetail(
    GetRecyclingProcessDetail event,
    Emitter<RecyclingState> emit,
  ) async {
    try {
      emit(RecyclingLoading());
      
      final process = await repository.getRecyclingProcessDetail(event.id);
      
      emit(RecyclingProcessLoaded(process: process));
    } catch (e) {
      developer.log('Lỗi khi lấy chi tiết quy trình tái chế: $e', error: e);
      emit(RecyclingError(message: e.toString()));
    }
  }

  Future<void> _onCreateRecyclingProcess(
    CreateRecyclingProcess event,
    Emitter<RecyclingState> emit,
  ) async {
    try {
      emit(RecyclingLoading());
      
      final process = await repository.createRecyclingProcess(
        transactionId: event.transactionId,
        wasteTypeId: event.wasteTypeId,
        quantity: event.quantity,
        notes: event.notes,
      );
      
      emit(RecyclingProcessCreated(process: process));
    } catch (e) {
      developer.log('Lỗi khi tạo quy trình tái chế: $e', error: e);
      emit(RecyclingError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRecyclingProcess(
    UpdateRecyclingProcess event,
    Emitter<RecyclingState> emit,
  ) async {
    try {
      emit(RecyclingLoading());
      
      final process = await repository.updateRecyclingProcess(
        id: event.id,
        updateData: event.updateData,
      );
      
      emit(RecyclingProcessUpdated(process: process));
    } catch (e) {
      developer.log('Lỗi khi cập nhật quy trình tái chế: $e', error: e);
      emit(RecyclingError(message: e.toString()));
    }
  }

  Future<void> _onGetRecyclingReport(
    GetRecyclingReport event,
    Emitter<RecyclingState> emit,
  ) async {
    try {
      emit(RecyclingLoading());
      
      final report = await repository.getRecyclingReport(
        fromDate: event.fromDate,
        toDate: event.toDate,
        wasteTypeId: event.wasteTypeId,
      );
      
      emit(RecyclingReportLoaded(report: report));
    } catch (e) {
      developer.log('Lỗi khi lấy báo cáo thống kê tái chế: $e', error: e);
      emit(RecyclingError(message: e.toString()));
    }
  }

  Future<void> _onGetRecyclingStatistics(
    GetRecyclingStatistics event,
    Emitter<RecyclingState> emit,
  ) async {
    try {
      emit(RecyclingLoading());
      
      final statistics = await repository.getRecyclingStatistics(
        fromDate: event.fromDate,
        toDate: event.toDate,
        wasteTypeId: event.wasteTypeId,
      );
      
      emit(RecyclingStatisticsLoaded(statistics: statistics));
    } catch (e) {
      developer.log('Lỗi khi lấy thống kê số liệu tái chế: $e', error: e);
      emit(RecyclingError(message: e.toString()));
    }
  }

  Future<void> _onGetUserRecyclingProcesses(
    GetUserRecyclingProcesses event,
    Emitter<RecyclingState> emit,
  ) async {
    try {
      emit(RecyclingLoading());
      
      final processes = await repository.getUserRecyclingProcesses(event.userId);
      
      emit(UserRecyclingProcessesLoaded(
        processes: processes,
        userId: event.userId,
      ));
    } catch (e) {
      developer.log('Lỗi khi lấy quy trình tái chế của người dùng: $e', error: e);
      emit(RecyclingError(message: e.toString()));
    }
  }

  Future<void> _onSendRecyclingNotification(
    SendRecyclingNotification event,
    Emitter<RecyclingState> emit,
  ) async {
    try {
      emit(RecyclingLoading());
      
      final success = await repository.sendRecyclingNotification(
        event.id,
        event.message,
      );
      
      if (success) {
        emit(RecyclingNotificationSent(
          id: event.id,
          message: event.message,
        ));
      } else {
        emit(const RecyclingError(message: 'Không thể gửi thông báo'));
      }
    } catch (e) {
      developer.log('Lỗi khi gửi thông báo cập nhật quy trình tái chế: $e', error: e);
      emit(RecyclingError(message: e.toString()));
    }
  }
}
