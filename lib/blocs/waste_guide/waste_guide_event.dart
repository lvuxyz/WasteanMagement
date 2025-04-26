import 'package:equatable/equatable.dart';

abstract class WasteGuideEvent extends Equatable {
  const WasteGuideEvent();

  @override
  List<Object?> get props => [];
}

// Event để tải dữ liệu hướng dẫn phân loại
class LoadWasteGuide extends WasteGuideEvent {}

// Event để lọc theo loại rác cụ thể
class FilterWasteGuideByCategory extends WasteGuideEvent {
  final String category;

  const FilterWasteGuideByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

// Event để tìm kiếm trong hướng dẫn
class SearchWasteGuide extends WasteGuideEvent {
  final String query;

  const SearchWasteGuide(this.query);

  @override
  List<Object?> get props => [query];
}