import 'package:equatable/equatable.dart';

// Lớp mô hình dữ liệu cho danh mục phân loại rác
class WasteGuideCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final List<WasteGuideItem> items;

  WasteGuideCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.items,
  });
}

// Lớp mô hình dữ liệu cho mục phân loại rác cụ thể
class WasteGuideItem {
  final String id;
  final String name;
  final String description;
  final List<String> examples;
  final String instructions;

  WasteGuideItem({
    required this.id,
    required this.name,
    required this.description,
    required this.examples,
    required this.instructions,
  });
}

abstract class WasteGuideState extends Equatable {
  const WasteGuideState();

  @override
  List<Object?> get props => [];
}

// Trạng thái ban đầu khi màn hình được khởi tạo
class WasteGuideInitial extends WasteGuideState {}

// Trạng thái đang tải dữ liệu
class WasteGuideLoading extends WasteGuideState {}

// Trạng thái đã tải dữ liệu thành công
class WasteGuideLoaded extends WasteGuideState {
  final List<WasteGuideCategory> categories;
  final List<WasteGuideCategory> filteredCategories;
  final String selectedCategory;
  final String searchQuery;

  const WasteGuideLoaded({
    required this.categories,
    required this.filteredCategories,
    this.selectedCategory = '',
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [categories, filteredCategories, selectedCategory, searchQuery];

  WasteGuideLoaded copyWith({
    List<WasteGuideCategory>? categories,
    List<WasteGuideCategory>? filteredCategories,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return WasteGuideLoaded(
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Trạng thái khi có lỗi
class WasteGuideError extends WasteGuideState {
  final String message;

  const WasteGuideError(this.message);

  @override
  List<Object?> get props => [message];
}