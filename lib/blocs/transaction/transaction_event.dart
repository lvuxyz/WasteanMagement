import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTransactions extends TransactionEvent {
  final int page;
  final int limit;
  final String? status;

  FetchTransactions({
    this.page = 1,
    this.limit = 4,
    this.status,
  });

  @override
  List<Object?> get props => [page, limit, status];
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
    this.limit = 4,
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