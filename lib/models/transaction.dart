class Transaction {
  final int transactionId;
  final int userId;
  final int collectionPointId;
  final int wasteTypeId;
  final double quantity;
  final String unit;
  final DateTime transactionDate;
  final String status;
  final String? proofImageUrl;
  final String? userName;
  final String? username;
  final String collectionPointName;
  final String wasteTypeName;

  Transaction({
    required this.transactionId,
    required this.userId,
    required this.collectionPointId,
    required this.wasteTypeId,
    required this.quantity,
    required this.unit,
    required this.transactionDate,
    required this.status,
    this.proofImageUrl,
    this.userName,
    this.username,
    required this.collectionPointName,
    required this.wasteTypeName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    try {
      // Print the transaction data for debugging
      print('Parsing transaction: ${json['transaction_id']}');
      
      return Transaction(
        transactionId: json['transaction_id'],
        userId: json['user_id'],
        collectionPointId: json['collection_point_id'],
        wasteTypeId: json['waste_type_id'],
        quantity: json['quantity'] is int 
            ? json['quantity'].toDouble() 
            : json['quantity'],
        unit: json['unit'],
        transactionDate: DateTime.parse(json['transaction_date']),
        status: json['status'],
        proofImageUrl: json['proof_image_url'],
        userName: json['user_name'], // Can be null
        username: json['username'], // Can be null
        collectionPointName: json['collection_point_name'],
        wasteTypeName: json['waste_type_name'],
      );
    } catch (e) {
      print('Error parsing Transaction: $e');
      print('JSON: $json');
      rethrow;
    }
  }
}

class TransactionPagination {
  final int total;
  final int page;
  final int limit;
  final int pages;

  TransactionPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory TransactionPagination.fromJson(Map<String, dynamic> json) {
    try {
      return TransactionPagination(
        total: json['total'],
        page: json['page'],
        limit: json['limit'],
        pages: json['pages'],
      );
    } catch (e) {
      print('Error parsing TransactionPagination: $e');
      print('JSON: $json');
      rethrow;
    }
  }
}

class TransactionResponse {
  final bool success;
  final String message;
  final List<Transaction> data;
  final TransactionPagination pagination;

  TransactionResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing TransactionResponse: $json');
      
      // Check if data exists and is a list
      if (!json.containsKey('data') || json['data'] == null) {
        print('Warning: No data key found in response');
        return TransactionResponse(
          success: json['success'] ?? false,
          message: json['message'] ?? 'No data found in response',
          data: [],
          pagination: json.containsKey('pagination') 
              ? TransactionPagination.fromJson(json['pagination'])
              : TransactionPagination(total: 0, page: 1, limit: 10, pages: 0),
        );
      }
      
      final List<dynamic> dataJson = json['data'];
      final List<Transaction> transactions = dataJson
          .map((item) => Transaction.fromJson(item))
          .toList();

      return TransactionResponse(
        success: json['success'],
        message: json['message'],
        data: transactions,
        pagination: TransactionPagination.fromJson(json['pagination']),
      );
    } catch (e) {
      print('Error parsing TransactionResponse: $e');
      print('JSON: $json');
      rethrow;
    }
  }
} 