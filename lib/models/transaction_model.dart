class Transaction {
  final String id;
  final String userId;
  final String collectionPointId;
  final String collectionPointName;
  final String wasteTypeId;
  final String wasteTypeName;
  final double quantity;
  final String unit;
  final double points;
  final String status;
  final DateTime transactionDate;
  final String? notes;
  final String? imageUrl;

  Transaction({
    required this.id,
    required this.userId,
    required this.collectionPointId,
    required this.collectionPointName,
    required this.wasteTypeId,
    required this.wasteTypeName,
    required this.quantity,
    required this.unit,
    required this.points,
    required this.status,
    required this.transactionDate,
    this.notes,
    this.imageUrl,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      collectionPointId: json['collection_point_id'].toString(),
      collectionPointName: json['collection_point_name'] ?? '',
      wasteTypeId: json['waste_type_id'].toString(),
      wasteTypeName: json['waste_type_name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      points: (json['points'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      transactionDate: json['transaction_date'] != null 
          ? DateTime.parse(json['transaction_date']) 
          : DateTime.now(),
      notes: json['notes'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'collection_point_id': collectionPointId,
      'collection_point_name': collectionPointName,
      'waste_type_id': wasteTypeId,
      'waste_type_name': wasteTypeName,
      'quantity': quantity,
      'unit': unit,
      'points': points,
      'status': status,
      'transaction_date': transactionDate.toIso8601String(),
      'notes': notes,
      'image_url': imageUrl,
    };
  }
} 