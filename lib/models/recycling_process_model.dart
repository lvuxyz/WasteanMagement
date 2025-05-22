class RecyclingProcess {
  final String id;
  final String transactionId;
  final String wasteTypeId;
  final String wasteTypeName;
  final double? quantity;
  final double? processedQuantity;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final String? processedBy;
  final String? userId;
  final String? imageUrl;

  RecyclingProcess({
    required this.id,
    required this.transactionId,
    required this.wasteTypeId,
    required this.wasteTypeName,
    this.quantity,
    this.processedQuantity,
    required this.status,
    required this.startDate,
    this.endDate,
    this.notes,
    this.processedBy,
    this.userId,
    this.imageUrl,
  });

  factory RecyclingProcess.fromJson(Map<String, dynamic> json) {
    return RecyclingProcess(
      id: json['process_id']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      wasteTypeId: json['waste_type_id']?.toString() ?? '',
      wasteTypeName: json['waste_type_name'] ?? '',
      quantity: json['quantity'] != null ? (json['quantity']).toDouble() : null,
      processedQuantity: json['processed_quantity'] != null 
          ? double.tryParse(json['processed_quantity'].toString())
          : null,
      status: json['status'] ?? 'pending',
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : DateTime.now(),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      notes: json['notes'],
      processedBy: json['processed_by'],
      userId: json['user_id']?.toString(),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'process_id': id,
      'transaction_id': transactionId,
      'waste_type_id': wasteTypeId,
      'waste_type_name': wasteTypeName,
      'quantity': quantity,
      'processed_quantity': processedQuantity,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'notes': notes,
      'processed_by': processedBy,
      'user_id': userId,
      'image_url': imageUrl,
    };
  }

  RecyclingProcess copyWith({
    String? id,
    String? transactionId,
    String? wasteTypeId,
    String? wasteTypeName,
    double? quantity,
    double? processedQuantity,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? processedBy,
    String? userId,
    String? imageUrl,
  }) {
    return RecyclingProcess(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      wasteTypeId: wasteTypeId ?? this.wasteTypeId,
      wasteTypeName: wasteTypeName ?? this.wasteTypeName,
      quantity: quantity ?? this.quantity,
      processedQuantity: processedQuantity ?? this.processedQuantity,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      processedBy: processedBy ?? this.processedBy,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'RecyclingProcess{id: $id, transactionId: $transactionId, wasteTypeId: $wasteTypeId, status: $status}';
  }
} 