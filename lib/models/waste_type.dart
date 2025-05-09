class WasteType {
  final int id;
  final String name;
  final String description;
  final double unitPrice;
  final bool? recyclable;
  
  WasteType({
    required this.id,
    required this.name,
    required this.description,
    required this.unitPrice,
    this.recyclable,
  });
  
  factory WasteType.fromJson(Map<String, dynamic> json) {
    return WasteType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      unitPrice: json['unit_price']?.toDouble(),
      recyclable: json['recyclable'],
    );
  }
} 