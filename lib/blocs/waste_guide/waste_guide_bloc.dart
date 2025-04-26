import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'waste_guide_event.dart';
import 'waste_guide_state.dart';

class WasteGuideBloc extends Bloc<WasteGuideEvent, WasteGuideState> {
  WasteGuideBloc() : super(WasteGuideInitial()) {
    on<LoadWasteGuide>(_onLoadWasteGuide);
    on<FilterWasteGuideByCategory>(_onFilterWasteGuideByCategory);
    on<SearchWasteGuide>(_onSearchWasteGuide);
  }

  Future<void> _onLoadWasteGuide(
      LoadWasteGuide event,
      Emitter<WasteGuideState> emit,
      ) async {
    emit(WasteGuideLoading());
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mẫu dữ liệu cho hướng dẫn phân loại rác
      // Trong tương lai có thể thay thế bằng gọi API
      final categories = _getMockWasteGuideCategories();

      emit(WasteGuideLoaded(
        categories: categories,
        filteredCategories: categories,
      ));
    } catch (e) {
      emit(WasteGuideError('Không thể tải hướng dẫn phân loại rác: $e'));
    }
  }

  void _onFilterWasteGuideByCategory(
      FilterWasteGuideByCategory event,
      Emitter<WasteGuideState> emit,
      ) {
    if (state is WasteGuideLoaded) {
      final currentState = state as WasteGuideLoaded;
      final category = event.category;

      if (category.isEmpty || category == 'Tất cả') {
        emit(currentState.copyWith(
          filteredCategories: currentState.categories,
          selectedCategory: category,
        ));
      } else {
        final filtered = currentState.categories
            .where((c) => c.name == category)
            .toList();

        emit(currentState.copyWith(
          filteredCategories: filtered,
          selectedCategory: category,
        ));
      }
    }
  }

  void _onSearchWasteGuide(
      SearchWasteGuide event,
      Emitter<WasteGuideState> emit,
      ) {
    if (state is WasteGuideLoaded) {
      final currentState = state as WasteGuideLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredCategories: currentState.categories,
          searchQuery: query,
        ));
      } else {
        // Tìm kiếm trong các danh mục và các mục con
        final filtered = currentState.categories.where((category) {
          if (category.name.toLowerCase().contains(query) ||
              category.description.toLowerCase().contains(query)) {
            return true;
          }

          // Tìm kiếm trong các mục con
          final hasMatchingItems = category.items.any((item) =>
          item.name.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query) ||
              item.examples.any((example) => example.toLowerCase().contains(query)));

          return hasMatchingItems;
        }).toList();

        emit(currentState.copyWith(
          filteredCategories: filtered,
          searchQuery: query,
        ));
      }
    }
  }

  // Phương thức tạo dữ liệu mẫu cho hướng dẫn phân loại
  List<WasteGuideCategory> _getMockWasteGuideCategories() {
    return [
      WasteGuideCategory(
        id: 'recyclable',
        name: 'Rác tái chế',
        description: 'Rửa sạch và làm khô trước khi phân loại',
        iconName: 'recycling',
        items: [
          WasteGuideItem(
            id: 'plastic',
            name: 'Nhựa',
            description: 'Các loại nhựa có thể tái chế',
            examples: ['Chai nước', 'Túi ni-lông sạch', 'Hộp đựng thực phẩm'],
            instructions: 'Rửa sạch, làm khô và nén lại trước khi mang đi tái chế.',
          ),
          WasteGuideItem(
            id: 'paper',
            name: 'Giấy, bìa carton',
            description: 'Các loại giấy và bìa carton có thể tái chế',
            examples: ['Báo, tạp chí', 'Hộp carton', 'Sách vở cũ'],
            instructions: 'Tháo bỏ băng keo, ghim, giữ khô ráo và xếp gọn.',
          ),
          WasteGuideItem(
            id: 'metal',
            name: 'Kim loại',
            description: 'Các vật dụng bằng kim loại có thể tái chế',
            examples: ['Lon nước ngọt', 'Đồ hộp', 'Vật dụng kim loại nhỏ'],
            instructions: 'Rửa sạch, làm khô và nén lại nếu có thể.',
          ),
          WasteGuideItem(
            id: 'glass',
            name: 'Kính, thủy tinh',
            description: 'Các vật dụng bằng thủy tinh có thể tái chế',
            examples: ['Chai rượu, bia', 'Lọ đựng gia vị', 'Chai mỹ phẩm'],
            instructions: 'Rửa sạch, tháo bỏ nắp kim loại và nhãn giấy.',
          ),
        ],
      ),
      WasteGuideCategory(
        id: 'organic',
        name: 'Rác hữu cơ',
        description: 'Có thể ủ làm phân compost',
        iconName: 'compost',
        items: [
          WasteGuideItem(
            id: 'food_waste',
            name: 'Thực phẩm',
            description: 'Các loại rác thải thực phẩm',
            examples: ['Thức ăn thừa', 'Vỏ trái cây', 'Bã cà phê'],
            instructions: 'Thu gom riêng, có thể ủ làm phân compost hoặc làm thức ăn cho vật nuôi.',
          ),
          WasteGuideItem(
            id: 'garden_waste',
            name: 'Rác vườn',
            description: 'Các loại rác từ vườn',
            examples: ['Lá cây', 'Cành cây nhỏ', 'Cỏ cắt'],
            instructions: 'Có thể cắt nhỏ để ủ phân compost nhanh hơn.',
          ),
        ],
      ),
      WasteGuideCategory(
        id: 'hazardous',
        name: 'Rác nguy hại',
        description: 'Cần xử lý đặc biệt, không vứt lẫn với rác thường',
        iconName: 'warning',
        items: [
          WasteGuideItem(
            id: 'battery',
            name: 'Pin, ắc quy',
            description: 'Các loại pin và ắc quy đã qua sử dụng',
            examples: ['Pin alkaline', 'Pin sạc', 'Ắc quy điện thoại'],
            instructions: 'Cần thu gom riêng, mang đến điểm thu gom chuyên dụng.',
          ),
          WasteGuideItem(
            id: 'electronic',
            name: 'Thiết bị điện tử',
            description: 'Các thiết bị điện tử hỏng hoặc không còn sử dụng',
            examples: ['Điện thoại cũ', 'Máy tính', 'Thiết bị điện gia dụng'],
            instructions: 'Mang đến các điểm thu mua điện tử cũ hoặc điểm tái chế chuyên dụng.',
          ),
          WasteGuideItem(
            id: 'chemical',
            name: 'Hóa chất',
            description: 'Các loại hóa chất nguy hại',
            examples: ['Thuốc trừ sâu', 'Dung môi', 'Sơn, dầu'],
            instructions: 'Đựng trong hộp kín, không đổ xuống cống rãnh, mang đến điểm thu gom đặc biệt.',
          ),
          WasteGuideItem(
            id: 'medical',
            name: 'Rác y tế',
            description: 'Các loại rác thải y tế',
            examples: ['Thuốc hết hạn', 'Kim tiêm', 'Băng gạc y tế'],
            instructions: 'Bọc kĩ, dán nhãn rõ ràng và mang đến các điểm thu gom chuyên dụng.',
          ),
        ],
      ),
      WasteGuideCategory(
        id: 'general',
        name: 'Rác thường',
        description: 'Rác không thể tái chế hoặc xử lý',
        iconName: 'delete',
        items: [
          WasteGuideItem(
            id: 'mixed_waste',
            name: 'Rác thải hỗn hợp',
            description: 'Các loại rác khó phân loại',
            examples: ['Tã lót', 'Băng vệ sinh', 'Bao bì nhiều lớp'],
            instructions: 'Bọc kín và vứt vào thùng rác thường.',
          ),
          WasteGuideItem(
            id: 'difficult_materials',
            name: 'Vật liệu khó phân hủy',
            description: 'Các vật liệu khó phân hủy',
            examples: ['Xốp', 'Túi ni-lông bẩn', 'Đồ nhựa dùng một lần'],
            instructions: 'Cố gắng giảm thiểu sử dụng các vật liệu này.',
          ),
        ],
      ),
    ];
  }
}