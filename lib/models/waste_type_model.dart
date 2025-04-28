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
    return WasteType(
      id: json['waste_type_id'],
      name: json['name'],
      description: json['description'],
      recyclable: json['recyclable'] == 1,
      handlingInstructions: json['handling_instructions'],
      unitPrice: double.parse(json['unit_price'].toString()),
      icon: Icons.delete_outline,
      color: Colors.green,
      category: json['recyclable'] == 1 ? 'Tái chế' : 'Thường',
      examples: const [],
      unit: 'kg',
      recentPoints: '',
    );
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