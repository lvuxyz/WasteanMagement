class WasteType {
  final int id;
  final String name;
  final String description;
  final bool recyclable;
  final String handlingInstructions;
  final double unitPrice;
  final String imageUrl;

  WasteType({
    required this.id,
    required this.name,
    required this.description,
    required this.recyclable,
    required this.handlingInstructions,
    required this.unitPrice,
    this.imageUrl = '',
  });

  factory WasteType.fromJson(Map<String, dynamic> json) {
    return WasteType(
      id: json['waste_type_id'],
      name: json['name'],
      description: json['description'] ?? '',
      recyclable: json['recyclable'] == 1,
      handlingInstructions: json['handling_instructions'] ?? '',
      unitPrice: (json['unit_price'] as num).toDouble(),
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waste_type_id': id,
      'name': name,
      'description': description,
      'recyclable': recyclable ? 1 : 0,
      'handling_instructions': handlingInstructions,
      'unit_price': unitPrice,
      'image_url': imageUrl,
    };
  }
} 