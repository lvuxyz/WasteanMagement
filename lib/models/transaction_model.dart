class Transaction {
  final int id;
  final int userId;
  final int collectionPointId;
  final int wasteTypeId;
  final double quantity;
  final String unit;
  final DateTime transactionDate;
  final String status;
  final String proofImageUrl;
  final String wasteName; // For display purposes

  Transaction({
    required this.id,
    required this.userId,
    required this.collectionPointId,
    required this.wasteTypeId,
    required this.quantity,
    this.unit = 'kg',
    required this.transactionDate,
    this.status = 'pending',
    this.proofImageUrl = '',
    this.wasteName = '',
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['transaction_id'],
      userId: json['user_id'],
      collectionPointId: json['collection_point_id'],
      wasteTypeId: json['waste_type_id'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] ?? 'kg',
      transactionDate: DateTime.parse(json['transaction_date']),
      status: json['status'] ?? 'pending',
      proofImageUrl: json['proof_image_url'] ?? '',
      wasteName: json['waste_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': id,
      'user_id': userId,
      'collection_point_id': collectionPointId,
      'waste_type_id': wasteTypeId,
      'quantity': quantity,
      'unit': unit,
      'transaction_date': transactionDate.toIso8601String(),
      'status': status,
      'proof_image_url': proofImageUrl,
    };
  }
} 