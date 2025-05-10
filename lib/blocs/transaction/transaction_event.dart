import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTransactions extends TransactionEvent {
  final int page;
  final int limit;
  final String? status;
  final bool isAdmin;

  FetchTransactions({
    this.page = 1,
    this.limit = 10,
    this.status,
    this.isAdmin = false,
  });

  @override
  List<Object?> get props => [page, limit, status, isAdmin];
}

class FetchMyTransactions extends TransactionEvent {
  final int page;
  final int limit;
  final String? status;
  final int? collectionPointId;
  final int? wasteTypeId;
  final String? dateFrom;
  final String? dateTo;

  FetchMyTransactions({
    this.page = 1,
    this.limit = 10,
    this.status,
    this.collectionPointId,
    this.wasteTypeId,
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [page, limit, status, collectionPointId, wasteTypeId, dateFrom, dateTo];
}

class RefreshTransactions extends TransactionEvent {}

class CreateTransaction extends TransactionEvent {
  final int collectionPointId;
  final int wasteTypeId;
  final double quantity;
  final String unit;
  final String? proofImageUrl;

  CreateTransaction({
    required this.collectionPointId,
    required this.wasteTypeId,
    required this.quantity,
    required this.unit,
    this.proofImageUrl,
  });

  @override
  List<Object?> get props => [collectionPointId, wasteTypeId, quantity, unit, proofImageUrl];
}

class UpdateTransactionStatus extends TransactionEvent {
  final int transactionId;
  final String status;

  UpdateTransactionStatus({
    required this.transactionId,
    required this.status,
  });

  @override
  List<Object?> get props => [transactionId, status];
}

class DeleteTransaction extends TransactionEvent {
  final int transactionId;

  DeleteTransaction({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class SearchTransactions extends TransactionEvent {
  final String query;

  SearchTransactions(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateTransaction extends TransactionEvent {
  final int transactionId;
  final int collectionPointId;
  final int wasteTypeId;
  final double quantity;
  final String unit;
  final String? proofImageUrl;

  UpdateTransaction({
    required this.transactionId,
    required this.collectionPointId,
    required this.wasteTypeId,
    required this.quantity,
    required this.unit,
    this.proofImageUrl,
  });

  @override
  List<Object?> get props => [transactionId, collectionPointId, wasteTypeId, quantity, unit, proofImageUrl];
}

class FetchTransactionHistory extends TransactionEvent {
  final int transactionId;

  FetchTransactionHistory({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
} 