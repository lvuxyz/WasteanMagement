class RecyclingRecord {
  final String id;
  final String wasteTypeId;
  final String wasteTypeName;
  final String wasteTypeCategory;
  final double weight;
  final String collectionPointId;
  final String collectionPointName;
  final DateTime date;
  final String userId;
  final bool isVerified;
  final String? imageUrl;
  final int? rewardPoints;

  RecyclingRecord({
    required this.id,
    required this.wasteTypeId,
    required this.wasteTypeName,
    required this.wasteTypeCategory,
    required this.weight,
    required this.collectionPointId,
    required this.collectionPointName,
    required this.date,
    required this.userId,
    required this.isVerified,
    this.imageUrl,
    this.rewardPoints,
  });

  factory RecyclingRecord.fromJson(Map<String, dynamic> json) {
    return RecyclingRecord(
      id: json['id'] ?? '',
      wasteTypeId: json['wasteTypeId'] ?? '',
      wasteTypeName: json['wasteTypeName'] ?? '',
      wasteTypeCategory: json['wasteTypeCategory'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      collectionPointId: json['collectionPointId'] ?? '',
      collectionPointName: json['collectionPointName'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      userId: json['userId'] ?? '',
      isVerified: json['isVerified'] ?? false,
      imageUrl: json['imageUrl'],
      rewardPoints: json['rewardPoints'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wasteTypeId': wasteTypeId,
      'wasteTypeName': wasteTypeName,
      'wasteTypeCategory': wasteTypeCategory,
      'weight': weight,
      'collectionPointId': collectionPointId,
      'collectionPointName': collectionPointName,
      'date': date.toIso8601String(),
      'userId': userId,
      'isVerified': isVerified,
      'imageUrl': imageUrl,
      'rewardPoints': rewardPoints,
    };
  }
} 