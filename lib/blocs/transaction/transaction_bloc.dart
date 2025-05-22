import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_event.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_state.dart';
import 'package:wasteanmagement/repositories/transaction_repository.dart';
import 'package:wasteanmagement/services/auth_service.dart';
import 'package:wasteanmagement/models/transaction.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;
  final AuthService _authService = AuthService();

  // ignore: avoid_print
  void _log(String message) => print(message);

  TransactionBloc({required this.transactionRepository}) 
      : super(const TransactionState()) {
    on<FetchTransactions>(_onFetchTransactions);
    on<FetchMyTransactions>(_onFetchMyTransactions);
    on<RefreshTransactions>(_onRefreshTransactions);
    on<CreateTransaction>(_onCreateTransaction);
    on<UpdateTransactionStatus>(_onUpdateTransactionStatus);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<SearchTransactions>(_onSearchTransactions);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<FetchTransactionHistory>(_onFetchTransactionHistory);
  }

  Future<void> _onFetchTransactions(
    FetchTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state.hasReachedMax && event.page > state.currentPage) return;
    
    try {
      if (state.status == TransactionStatus.initial) {
        emit(state.copyWith(status: TransactionStatus.loading));
      }

      final response = await transactionRepository.getTransactions(
        page: event.page,
        limit: event.limit,
        status: event.status,
        isAdmin: event.isAdmin,
      );

      if (!response.success) {
        throw Exception(response.message);
      }

      final newTransactions = response.data;
      final hasReachedMax = event.page >= response.pagination.pages;

      emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: event.page > 1 
            ? [...state.transactions, ...newTransactions] 
            : newTransactions,
        hasReachedMax: hasReachedMax,
        currentPage: event.page,
        totalPages: response.pagination.pages,
      ));
    } catch (e) {
      _log('Error fetching transactions: $e');
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchMyTransactions(
    FetchMyTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state.hasReachedMax && event.page > state.currentPage) return;
    
    try {
      if (state.status == TransactionStatus.initial) {
        emit(state.copyWith(status: TransactionStatus.loading));
      }

      final response = await transactionRepository.getMyTransactions(
        page: event.page,
        limit: event.limit,
        status: event.status,
        collectionPointId: event.collectionPointId,
        wasteTypeId: event.wasteTypeId,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      if (!response.success) {
        throw Exception(response.message);
      }

      final newTransactions = response.data;
      final hasReachedMax = event.page >= response.pagination.pages;

      emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: event.page > 1 
            ? [...state.transactions, ...newTransactions] 
            : newTransactions,
        hasReachedMax: hasReachedMax,
        currentPage: event.page,
        totalPages: response.pagination.pages,
      ));
    } catch (e) {
      _log('Error fetching my transactions: $e');
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionState(status: TransactionStatus.loading));
    
    try {
      // Lấy token để kiểm tra
      final token = await _authService.getToken();
      _log('RefreshTransactions - checking token: ${token != null ? "Token found" : "No token"}');
      
      final isAdmin = await _authService.isAdmin();
      _log('RefreshTransactions - User is admin: $isAdmin');
      
      if (isAdmin) {
        _log('Fetching all transactions as admin with admin API endpoint');
        final response = await transactionRepository.getTransactions(
          page: 1, 
          limit: 10,
          isAdmin: true, // Đảm bảo đặt cờ isAdmin=true
        );
        
        if (!response.success) {
          throw Exception(response.message);
        }
        
        emit(TransactionState(
          status: TransactionStatus.success,
          transactions: response.data,
          hasReachedMax: 1 >= response.pagination.pages,
          currentPage: 1,
          totalPages: response.pagination.pages,
        ));
      } else {
        _log('Fetching my transactions as regular user with my-transactions endpoint');
        final response = await transactionRepository.getMyTransactions(page: 1, limit: 10);
        
        if (!response.success) {
          throw Exception(response.message);
        }
        
        emit(TransactionState(
          status: TransactionStatus.success,
          transactions: response.data,
          hasReachedMax: 1 >= response.pagination.pages,
          currentPage: 1,
          totalPages: response.pagination.pages,
        ));
      }
    } catch (e) {
      _log('Error refreshing transactions: $e');
      emit(TransactionState(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateTransaction(
    CreateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TransactionStatus.loading));
      
      final response = await transactionRepository.createTransaction(
        collectionPointId: event.collectionPointId,
        wasteTypeId: event.wasteTypeId,
        quantity: event.quantity,
        unit: event.unit,
        proofImageUrl: event.proofImageUrl,
      );
      
      if (!response['success']) {
        throw Exception(response['message']);
      }
      
      // After creating, refresh the list
      add(RefreshTransactions());
    } catch (e) {
      _log('Error creating transaction: $e');
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateTransactionStatus(
    UpdateTransactionStatus event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TransactionStatus.loading));

      // Call the actual API endpoint
      final result = await transactionRepository.updateTransactionStatus(
        transactionId: event.transactionId,
        status: event.status,
      );

      if (!result['success']) {
        throw Exception(result['message']);
      }

      // After updating successfully, refresh the list to get the latest data
      add(RefreshTransactions());
    } catch (e) {
      _log('Error updating transaction status: $e');
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TransactionStatus.loading));

      // Call the actual API endpoint
      final result = await transactionRepository.deleteTransaction(event.transactionId);

      if (!result['success']) {
        throw Exception(result['message']);
      }

      // After deleting successfully, refresh the list to get the latest data
      add(RefreshTransactions());
    } catch (e) {
      _log('Error deleting transaction: $e');
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
  
  Future<void> _onSearchTransactions(
    SearchTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TransactionStatus.loading));
      
      // This would be implemented with actual API search
      // For now, just refresh transactions
      add(RefreshTransactions());
    } catch (e) {
      _log('Error searching transactions: $e');
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TransactionStatus.loading));

      // Call the actual API endpoint
      final result = await transactionRepository.updateTransaction(
        transactionId: event.transactionId,
        collectionPointId: event.collectionPointId,
        wasteTypeId: event.wasteTypeId,
        quantity: event.quantity,
        unit: event.unit,
        proofImageUrl: event.proofImageUrl,
      );

      if (!result['success']) {
        throw Exception(result['message']);
      }

      // After updating successfully, refresh the list to get the latest data
      add(RefreshTransactions());
    } catch (e) {
      _log('Error updating transaction: $e');
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchTransactionHistory(
    FetchTransactionHistory event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TransactionStatus.loading));

      // Call the repository to get transaction history
      final result = await transactionRepository.getTransactionHistory(
        event.transactionId,
      );

      List<TransactionHistory> history = [];
      
      if (result['success'] && result['data'] != null) {
        final historyData = result['data'] as List<dynamic>;
        history = historyData
            .map((item) => TransactionHistory.fromJson(item))
            .toList();
      }

      emit(state.copyWith(
        status: TransactionStatus.success,
        transactionHistory: history,
      ));
    } catch (e) {
      _log('Error fetching transaction history: $e');
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
        transactionHistory: [], // Provide an empty list on error
      ));
    }
  }
}