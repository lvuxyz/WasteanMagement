import 'package:equatable/equatable.dart';
import '../../models/waste_type_model.dart';

abstract class WasteTypeState extends Equatable {
  const WasteTypeState();

  @override
  List<Object?> get props => [];
}

class WasteTypeInitial extends WasteTypeState {}

class WasteTypeLoading extends WasteTypeState {}

class WasteTypeLoaded extends WasteTypeState {
  final List<WasteType> wasteTypes;
  final List<WasteType> filteredWasteTypes;
  final String searchQuery;
  final String selectedCategory;
  final int? selectedWasteTypeId;

  const WasteTypeLoaded({
    required this.wasteTypes,
    required this.filteredWasteTypes,
    this.searchQuery = '',
    this.selectedCategory = '',
    this.selectedWasteTypeId,
  });

  @override
  List<Object?> get props => [wasteTypes, filteredWasteTypes, searchQuery, selectedCategory, selectedWasteTypeId];

  WasteTypeLoaded copyWith({
    List<WasteType>? wasteTypes,
    List<WasteType>? filteredWasteTypes,
    String? searchQuery,
    String? selectedCategory,
    int? selectedWasteTypeId,
  }) {
    return WasteTypeLoaded(
      wasteTypes: wasteTypes ?? this.wasteTypes,
      filteredWasteTypes: filteredWasteTypes ?? this.filteredWasteTypes,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedWasteTypeId: selectedWasteTypeId ?? this.selectedWasteTypeId,
    );
  }
}

class WasteTypeError extends WasteTypeState {
  final String message;

  const WasteTypeError(this.message);

  @override
  List<Object?> get props => [message];
}

class RecyclingPlanUpdated extends WasteTypeState {
  final String message;

  const RecyclingPlanUpdated(this.message);

  @override
  List<Object?> get props => [message];
}