import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/waste_type_model.dart';
import '../../repositories/waste_type_repository.dart';
import 'waste_type_event.dart';
import 'waste_type_state.dart';

class WasteTypeBloc extends Bloc<WasteTypeEvent, WasteTypeState> {
  final WasteTypeRepository repository;

  WasteTypeBloc({required this.repository}) : super(WasteTypeInitial()) {
    on<LoadWasteTypes>(_onLoadWasteTypes);
    on<SearchWasteTypes>(_onSearchWasteTypes);
    on<FilterWasteTypesByCategory>(_onFilterWasteTypesByCategory);
    on<SelectWasteType>(_onSelectWasteType);
    on<AddToRecyclingPlan>(_onAddToRecyclingPlan);
  }

  Future<void> _onLoadWasteTypes(
      LoadWasteTypes event,
      Emitter<WasteTypeState> emit,
      ) async {
    emit(WasteTypeLoading());
    try {
      final wasteTypes = await repository.getWasteTypes();
      emit(WasteTypeLoaded(
        wasteTypes: wasteTypes,
        filteredWasteTypes: wasteTypes,
      ));
    } catch (e) {
      emit(WasteTypeError('Không thể tải danh sách loại rác: $e'));
    }
  }

  void _onSearchWasteTypes(
      SearchWasteTypes event,
      Emitter<WasteTypeState> emit,
      ) {
    if (state is WasteTypeLoaded) {
      final currentState = state as WasteTypeLoaded;
      final query = event.query.toLowerCase();

      List<WasteType> filteredList;

      if (query.isEmpty) {
        // Nếu query rỗng, lọc theo danh mục đang chọn (nếu có)
        if (currentState.selectedCategory.isEmpty || currentState.selectedCategory == 'Tất cả') {
          filteredList = currentState.wasteTypes;
        } else {
          filteredList = currentState.wasteTypes.where((wasteType) {
            return wasteType.category == currentState.selectedCategory;
          }).toList();
        }
      } else {
        // Lọc theo query và danh mục đang chọn
        filteredList = currentState.wasteTypes.where((wasteType) {
          final matchesQuery = wasteType.name.toLowerCase().contains(query) ||
              wasteType.description.toLowerCase().contains(query) ||
              wasteType.category.toLowerCase().contains(query);

          if (currentState.selectedCategory.isEmpty || currentState.selectedCategory == 'Tất cả') {
            return matchesQuery;
          } else {
            return matchesQuery && wasteType.category == currentState.selectedCategory;
          }
        }).toList();
      }

      emit(currentState.copyWith(
        filteredWasteTypes: filteredList,
        searchQuery: query,
      ));
    }
  }

  void _onFilterWasteTypesByCategory(
      FilterWasteTypesByCategory event,
      Emitter<WasteTypeState> emit,
      ) {
    if (state is WasteTypeLoaded) {
      final currentState = state as WasteTypeLoaded;
      final category = event.category;

      List<WasteType> filteredList;

      if (category.isEmpty || category == 'Tất cả') {
        // Nếu không có danh mục hoặc là 'Tất cả', lọc theo query hiện tại (nếu có)
        if (currentState.searchQuery.isEmpty) {
          filteredList = currentState.wasteTypes;
        } else {
          final query = currentState.searchQuery.toLowerCase();
          filteredList = currentState.wasteTypes.where((wasteType) {
            return wasteType.name.toLowerCase().contains(query) ||
                wasteType.description.toLowerCase().contains(query) ||
                wasteType.category.toLowerCase().contains(query);
          }).toList();
        }
      } else {
        // Lọc theo danh mục và query hiện tại (nếu có)
        filteredList = currentState.wasteTypes.where((wasteType) {
          final matchesCategory = wasteType.category == category;

          if (currentState.searchQuery.isEmpty) {
            return matchesCategory;
          } else {
            final query = currentState.searchQuery.toLowerCase();
            final matchesQuery = wasteType.name.toLowerCase().contains(query) ||
                wasteType.description.toLowerCase().contains(query) ||
                wasteType.category.toLowerCase().contains(query);

            return matchesCategory && matchesQuery;
          }
        }).toList();
      }

      emit(currentState.copyWith(
        filteredWasteTypes: filteredList,
        selectedCategory: category,
      ));
    }
  }

  void _onSelectWasteType(
      SelectWasteType event,
      Emitter<WasteTypeState> emit,
      ) {
    if (state is WasteTypeLoaded) {
      final currentState = state as WasteTypeLoaded;
      emit(currentState.copyWith(
        selectedWasteTypeId: event.wasteTypeId,
      ));
    }
  }

  Future<void> _onAddToRecyclingPlan(
      AddToRecyclingPlan event,
      Emitter<WasteTypeState> emit,
      ) async {
    final currentState = state;

    if (currentState is WasteTypeLoaded) {
      try {
        final success = await repository.addToRecyclingPlan(event.wasteTypeId);

        if (success) {
          emit(const RecyclingPlanUpdated('Đã thêm vào kế hoạch tái chế'));
          // Sau khi hiển thị thông báo, quay lại trạng thái trước đó
          emit(currentState);
        } else {
          emit(const WasteTypeError('Không thể thêm vào kế hoạch tái chế'));
          emit(currentState);
        }
      } catch (e) {
        emit(WasteTypeError('Lỗi: $e'));
        emit(currentState);
      }
    }
  }
}