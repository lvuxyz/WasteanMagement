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
    on<LoadWasteTypeDetails>(_onLoadWasteTypeDetails);
    on<LoadWasteTypeDetailsWithAvailablePoints>(_onLoadWasteTypeDetailsWithAvailablePoints);
    on<DeleteWasteType>(_onDeleteWasteType);
    on<LinkCollectionPoint>(_onLinkCollectionPoint);
    on<UnlinkCollectionPoint>(_onUnlinkCollectionPoint);
    on<CreateWasteType>(_onCreateWasteType);
    on<UpdateWasteType>(_onUpdateWasteType);
    on<UpdateWasteTypeData>(_onUpdateWasteTypeData);
    on<LoadWasteTypesForCollectionPoint>(_onLoadWasteTypesForCollectionPoint);
    on<AddWasteTypeToCollectionPoint>(_onAddWasteTypeToCollectionPoint);
  }

  Future<void> _onLoadWasteTypes(
      LoadWasteTypes event,
      Emitter<WasteTypeState> emit,
      ) async {
    emit(const WasteTypeLoading());
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
        filteredList = currentState.wasteTypes;
      } else {
        filteredList = currentState.wasteTypes
            .where((type) => 
                type.name.toLowerCase().contains(query) ||
                type.description.toLowerCase().contains(query) ||
                type.category.toLowerCase().contains(query) ||
                type.examples.any((example) => example.toLowerCase().contains(query)))
            .toList();
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
        filteredList = currentState.wasteTypes;
      } else {
        filteredList = currentState.wasteTypes
            .where((type) => type.category == category)
            .toList();
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
    try {
      final result = await repository.addToRecyclingPlan(event.wasteTypeId);
      if (result) {
        emit(const RecyclingPlanUpdated('Đã thêm loại rác vào kế hoạch tái chế thành công'));
      } else {
        emit(const WasteTypeError('Không thể thêm loại rác vào kế hoạch tái chế'));
      }
    } catch (e) {
      emit(WasteTypeError('Đã xảy ra lỗi khi thêm vào kế hoạch tái chế: $e'));
    }
  }

  Future<void> _onLoadWasteTypeDetails(
      LoadWasteTypeDetails event,
      Emitter<WasteTypeState> emit,
      ) async {
    emit(const WasteTypeLoading());
    try {
      final wasteType = await repository.getWasteTypeById(event.wasteTypeId);
      final collectionPoints = await repository.getCollectionPointsForWasteType(event.wasteTypeId);
      emit(WasteTypeDetailLoaded(
        wasteType: wasteType,
        collectionPoints: collectionPoints,
      ));
    } catch (e) {
      emit(WasteTypeError(e.toString()));
    }
  }

  Future<void> _onLoadWasteTypeDetailsWithAvailablePoints(
      LoadWasteTypeDetailsWithAvailablePoints event,
      Emitter<WasteTypeState> emit,
      ) async {
    emit(const WasteTypeLoading());
    try {
      final wasteType = await repository.getWasteTypeById(event.wasteTypeId);
      final linkedCollectionPoints = await repository.getCollectionPointsForWasteType(event.wasteTypeId);
      final allCollectionPoints = await repository.getAllCollectionPoints();
      
      emit(WasteTypeDetailLoaded(
        wasteType: wasteType,
        collectionPoints: linkedCollectionPoints,
        allCollectionPoints: allCollectionPoints,
      ));
    } catch (e) {
      emit(WasteTypeError(e.toString()));
    }
  }

  Future<void> _onDeleteWasteType(
      DeleteWasteType event,
      Emitter<WasteTypeState> emit,
      ) async {
    try {
      emit(WasteTypeLoading(
        isDeleting: true,
        deletingId: event.wasteTypeId,
      ));
      final result = await repository.deleteWasteType(event.wasteTypeId);
      if (result) {
        emit(WasteTypeDeleted(
          wasteTypeId: event.wasteTypeId,
          message: 'Đã xóa loại rác thành công',
        ));
        
        add(LoadWasteTypes());
      } else {
        emit(const WasteTypeError('Không thể xóa loại rác'));
      }
    } catch (e) {
      emit(WasteTypeError('Đã xảy ra lỗi khi xóa loại rác: $e'));
    }
  }

  Future<void> _onLinkCollectionPoint(
      LinkCollectionPoint event,
      Emitter<WasteTypeState> emit,
      ) async {
    try {
      final result = await repository.linkCollectionPoint(
        event.wasteTypeId,
        event.collectionPointId,
      );
      
      if (result) {
        emit(CollectionPointLinked(
          wasteTypeId: event.wasteTypeId,
          collectionPointId: event.collectionPointId,
        ));
        
        add(LoadWasteTypeDetailsWithAvailablePoints(event.wasteTypeId));
      } else {
        emit(const WasteTypeError('Không thể liên kết điểm thu gom'));
      }
    } catch (e) {
      emit(WasteTypeError('Đã xảy ra lỗi khi liên kết điểm thu gom: $e'));
    }
  }

  Future<void> _onUnlinkCollectionPoint(
      UnlinkCollectionPoint event,
      Emitter<WasteTypeState> emit,
      ) async {
    try {
      final result = await repository.unlinkCollectionPoint(
        event.wasteTypeId,
        event.collectionPointId,
      );
      
      if (result) {
        emit(CollectionPointUnlinked(
          wasteTypeId: event.wasteTypeId,
          collectionPointId: event.collectionPointId,
        ));
        
        add(LoadWasteTypeDetailsWithAvailablePoints(event.wasteTypeId));
      } else {
        emit(const WasteTypeError('Không thể hủy liên kết điểm thu gom'));
      }
    } catch (e) {
      emit(WasteTypeError('Đã xảy ra lỗi khi hủy liên kết điểm thu gom: $e'));
    }
  }

  Future<void> _onCreateWasteType(
    CreateWasteType event,
    Emitter<WasteTypeState> emit,
  ) async {
    emit(const WasteTypeLoading(isCreating: true));
    try {
      final Map<String, dynamic> wasteTypeData = {
        'name': event.name,
        'description': event.description,
        'recyclable': event.recyclable ? 1 : 0,
        'handling_instructions': event.handlingInstructions,
        'unit_price': event.unitPrice,
        'category': event.category,
        'examples': event.examples,
        'unit': event.unit,
      };
      
      final wasteType = await repository.createWasteType(wasteTypeData);
      emit(WasteTypeCreated(
        wasteType: wasteType,
        message: 'Đã tạo loại rác thành công',
      ));
      
      // Reload the waste types list
      add(LoadWasteTypes());
    } catch (e) {
      emit(WasteTypeError('Không thể tạo loại rác: $e'));
    }
  }

  Future<void> _onUpdateWasteType(
    UpdateWasteType event,
    Emitter<WasteTypeState> emit,
  ) async {
    emit(const WasteTypeLoading());
    try {
      final wasteType = await repository.updateWasteType(event.wasteType.id, event.wasteType.toJson());
      emit(WasteTypeUpdated(
        wasteType: wasteType,
        message: 'Đã cập nhật loại rác thành công',
      ));
      
      // Reload waste types list after successful update
      add(LoadWasteTypes());
    } catch (e) {
      emit(WasteTypeError('Không thể cập nhật loại rác: $e'));
    }
  }

  Future<void> _onUpdateWasteTypeData(
    UpdateWasteTypeData event,
    Emitter<WasteTypeState> emit,
  ) async {
    emit(const WasteTypeLoading());
    try {
      final wasteType = await repository.updateWasteType(event.wasteTypeId, event.data);
      emit(WasteTypeUpdated(
        wasteType: wasteType,
        message: 'Đã cập nhật loại rác thành công',
      ));
      
      // Reload waste types list after successful update
      add(LoadWasteTypes());
    } catch (e) {
      emit(WasteTypeError('Không thể cập nhật loại rác: $e'));
    }
  }

  Future<void> _onLoadWasteTypesForCollectionPoint(
    LoadWasteTypesForCollectionPoint event,
    Emitter<WasteTypeState> emit,
  ) async {
    emit(const WasteTypeLoading());
    try {
      final wasteTypes = await repository.getWasteTypesForCollectionPoint(event.collectionPointId);
      emit(WasteTypesForCollectionPointLoaded(
        collectionPointId: event.collectionPointId,
        collectionPointName: event.collectionPointName,
        wasteTypes: wasteTypes,
      ));
    } catch (e) {
      emit(WasteTypeError('Không thể tải danh sách loại rác cho điểm thu gom: $e'));
    }
  }

  Future<void> _onAddWasteTypeToCollectionPoint(
    AddWasteTypeToCollectionPoint event,
    Emitter<WasteTypeState> emit,
  ) async {
    try {
      // Since linkCollectionPoint is already implemented, we can reuse it
      // The API accepts the same parameters, just in a different order
      final result = await repository.linkCollectionPoint(
        event.wasteTypeId,
        event.collectionPointId,
      );
      
      if (result) {
        emit(WasteTypeAddedToCollectionPoint(
          wasteTypeId: event.wasteTypeId,
          collectionPointId: event.collectionPointId,
        ));
        
        // Reload the waste types for this collection point
        add(LoadWasteTypesForCollectionPoint(
          collectionPointId: event.collectionPointId,
          collectionPointName: '', // This will be updated when loaded
        ));
      } else {
        emit(const WasteTypeError('Không thể thêm loại rác vào điểm thu gom'));
      }
    } catch (e) {
      emit(WasteTypeError('Đã xảy ra lỗi khi thêm loại rác vào điểm thu gom: $e'));
    }
  }
}