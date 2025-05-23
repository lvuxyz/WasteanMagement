import 'package:equatable/equatable.dart';
import 'package:wasteanmagement/models/transaction.dart';

enum TransactionStatus { initial, loading, success, failure }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<Transaction> transactions;
  final bool hasReachedMax;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final List<TransactionHistory>? _transactionHistory;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.hasReachedMax = false,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    List<TransactionHistory>? transactionHistory,
  }) : _transactionHistory = transactionHistory;

  // Safe getter for transactionHistory that never returns null
  List<TransactionHistory> get transactionHistory => _transactionHistory ?? const [];

  TransactionState copyWith({
    TransactionStatus? status,
    List<Transaction>? transactions,
    bool? hasReachedMax,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    List<TransactionHistory>? transactionHistory,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      transactionHistory: transactionHistory ?? _transactionHistory,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    transactions, 
    hasReachedMax, 
    errorMessage, 
    currentPage, 
    totalPages,
    _transactionHistory,
  ];
} 