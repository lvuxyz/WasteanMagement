import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_event.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_state.dart';
import 'package:wasteanmagement/repositories/transaction_repository.dart';
import 'package:wasteanmagement/services/auth_service.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;
  final AuthService _authService = AuthService();

  TransactionBloc({required this.transactionRepository}) 
      : super(const TransactionState()) {
    on<FetchTransactions>(_onFetchTransactions);
    on<FetchMyTransactions>(_onFetchMyTransactions);
    on<RefreshTransactions>(_onRefreshTransactions);
    on<CreateTransaction>(_onCreateTransaction);
    on<UpdateTransactionStatus>(_onUpdateTransactionStatus);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<SearchTransactions>(_onSearchTransactions);
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
      print('Error fetching transactions: $e');
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
      print('Error fetching my transactions: $e');
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
      final isAdmin = await _authService.isAdmin();
      print('RefreshTransactions - User is admin: $isAdmin');
      
      if (isAdmin) {
        print('Fetching all transactions as admin');
        final response = await transactionRepository.getTransactions(page: 1, limit: 10);
        
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
        print('Fetching my transactions as regular user');
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
      print('Error refreshing transactions: $e');
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
      print('Error creating transaction: $e');
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

      // This would be the actual API call in a real app
      // await transactionRepository.updateTransactionStatus(
      //   transactionId: event.transactionId,
      //   status: event.status,
      // );

      // For now, just simulate the API call
      await Future.delayed(const Duration(seconds: 1));

      // Update the transaction in the current state
      final updatedTransactions = state.transactions.map((transaction) {
        if (transaction.transactionId == event.transactionId) {
          // In a real app, you'd create a copy of the transaction with the updated status
          // For now, we'll just simulate a successful update
          return transaction; // This would be replaced with an updated transaction
        }
        return transaction;
      }).toList();

      emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: updatedTransactions,
      ));

      // After updating, refresh the list to get the latest data
      add(RefreshTransactions());
    } catch (e) {
      print('Error updating transaction status: $e');
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

      // This would be the actual API call in a real app
      // await transactionRepository.deleteTransaction(event.transactionId);

      // For now, just simulate the API call
      await Future.delayed(const Duration(seconds: 1));

      // Remove the transaction from the current state
      final updatedTransactions = state.transactions
          .where((transaction) => transaction.transactionId != event.transactionId)
          .toList();

      emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: updatedTransactions,
      ));

      // After deleting, refresh the list to get the latest data
      add(RefreshTransactions());
    } catch (e) {
      print('Error deleting transaction: $e');
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
      print('Error searching transactions: $e');
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}