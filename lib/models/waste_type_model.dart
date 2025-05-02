import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class WasteType extends Equatable {
  final int id;
  final String name;
  final String description;
  final bool recyclable;
  final String handlingInstructions;
  final double unitPrice;
  final IconData icon;
  final Color color;
  final String category;
  final List<String> examples;
  final String unit;
  final String recentPoints;

  const WasteType({
    required this.id,
    required this.name,
    required this.description,
    required this.recyclable,
    required this.handlingInstructions,
    required this.unitPrice,
    required this.icon,
    required this.color,
    required this.category,
    required this.examples,
    required this.unit,
    required this.recentPoints,
  });

  factory WasteType.fromJson(Map<String, dynamic> json) {
    // Parse the recyclable field correctly
    final bool isRecyclable = json['recyclable'] == 1;
    
    // Determine category based on recyclable status
    String category = isRecyclable ? 'Tái chế' : 'Không tái chế';
    
    // Set icon based on recyclable status
    IconData iconData = isRecyclable ? Icons.recycling : Icons.delete_outline;
    
    // Set color based on recyclable status
    Color color = isRecyclable ? Colors.green : Colors.red;
    
    return WasteType(
      id: json['waste_type_id'],
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? 'No description available',
      recyclable: isRecyclable,
      handlingInstructions: json['handling_instructions'] ?? 'No handling instructions available',
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      icon: iconData,
      color: color,
      category: category,
      examples: json['examples'] != null 
          ? List<String>.from(json['examples']) 
          : [],
      unit: json['unit'] ?? 'kg',
      recentPoints: json['recent_points'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'recyclable': recyclable ? 1 : 0,
      'handling_instructions': handlingInstructions,
      'unit_price': unitPrice,
      'unit': unit,
      'examples': examples,
      // We don't send icon, color, or category as they're derived from recyclable
      // We don't send id as it's used in the URL path
    };
  }

  @override
  List<Object> get props => [
    id, 
    name, 
    description, 
    recyclable, 
    handlingInstructions, 
    unitPrice, 
    icon, 
    color, 
    category, 
    examples, 
    unit, 
    recentPoints
  ];
}