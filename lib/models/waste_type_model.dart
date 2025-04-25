import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class WasteType extends Equatable {
  final int id;
  final String name;
  final String category;
  final String description;
  final IconData icon;
  final Color color;
  final String recyclingMethod;
  final List<String> examples;
  final int buyingPrice;
  final String unit;
  final String recentPoints;

  const WasteType({
  required this.id,
  required this.name,
  required this.category,
  required this.description,
  required this.icon,
  required this.color,
  required this.recyclingMethod,
  required this.examples,
  required this.buyingPrice,
  required this.unit,
  required this.recentPoints,
});


  @override
  List<Object> get props => [id, name, category, description, icon, color, recyclingMethod, examples, buyingPrice, unit, recentPoints];
}