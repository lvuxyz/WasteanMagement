import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../blocs/admin/admin_cubit.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_tab_bar.dart';
import '../../widgets/common/search_field.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/waste_type/waste_type_item.dart';

class CollectionPointWasteTypesScreen extends StatefulWidget {
  final int collectionPointId;
  final String collectionPointName;

  const CollectionPointWasteTypesScreen({
    Key? key,
    required this.collectionPointId,
    required this.collectionPointName,
  }) : super(key: key);

  @override
  State<CollectionPointWasteTypesScreen> createState() => _CollectionPointWasteTypesScreenState();
}

class _CollectionPointWasteTypesScreenState extends State<CollectionPointWasteTypesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _linkedSearchController = TextEditingController();
  final TextEditingController _availableSearchController = TextEditingController();
  String _linkedSearchQuery = '';
  String _availableSearchQuery = '';
  List<WasteType> _allWasteTypes = [];
  List<WasteType> _linkedWasteTypes = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _linkedSearchController.addListener(_onLinkedSearchChanged);
    _availableSearchController.addListener(_onAvailableSearchChanged);
    
    // Load waste types for this collection point
    context.read<WasteTypeBloc>().add(LoadWasteTypesForCollectionPoint(
      collectionPointId: widget.collectionPointId,
      collectionPointName: widget.collectionPointName,
    ));
    
    // Load all waste types as well to show what can be added
    _loadAllWasteTypes();
    
    // Ensure admin status for this management screen
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<AdminCubit>().checkAdminStatus();
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        final currentState = context.read<AdminCubit>().state;
        if (!currentState) {
          context.read<AdminCubit>().forceUpdateAdminStatus(true);
        }
      }
    });
  }

  Future<void> _loadAllWasteTypes() async {
    // Load all waste types to show what's available to add
    context.read<WasteTypeBloc>().add(LoadWasteTypes());
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _linkedSearchController.dispose();
    _availableSearchController.dispose();
    super.dispose();
  }
  
  void _onLinkedSearchChanged() {
    setState(() {
      _linkedSearchQuery = _linkedSearchController.text;
    });
  }
  
  void _onAvailableSearchChanged() {
    setState(() {
      _availableSearchQuery = _availableSearchController.text;
    });
  }

  void _showUnlinkConfirmation(BuildContext context, int wasteTypeId, String name) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Xóa liên kết',
        content: 'Bạn có chắc chắn muốn xóa liên kết với loại rác "$name" không?',
        confirmText: 'Xóa liên kết',
        cancelText: 'Hủy',
        onConfirm: () {
          Navigator.of(context).pop();
          context.read<WasteTypeBloc>().add(
            UnlinkCollectionPoint(
              wasteTypeId: wasteTypeId,
              collectionPointId: widget.collectionPointId,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          'Quản lý loại rác thu gom: ${widget.collectionPointName}',
          style: const TextStyle(color: Colors.white),
        ),
        bottom: CustomTabBar(
          controller: _tabController,
          backgroundColor: AppColors.primaryGreen,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Đã liên kết'),
            Tab(text: 'Có thể thêm'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Reload both lists
              context.read<WasteTypeBloc>().add(LoadWasteTypesForCollectionPoint(
                collectionPointId: widget.collectionPointId,
                collectionPointName: widget.collectionPointName,
              ));
              _loadAllWasteTypes();
            },
          ),
        ],
      ),
      body: BlocConsumer<WasteTypeBloc, WasteTypeState>(
        listener: (context, state) {
          if (state is WasteTypeLoaded) {
            setState(() {
              _allWasteTypes = state.wasteTypes;
            });
          } else if (state is WasteTypesForCollectionPointLoaded) {
            setState(() {
              _linkedWasteTypes = state.wasteTypes;
            });
          } else if (state is WasteTypeAddedToCollectionPoint) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã thêm loại rác vào điểm thu gom thành công'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Reload data
            context.read<WasteTypeBloc>().add(LoadWasteTypesForCollectionPoint(
              collectionPointId: widget.collectionPointId,
              collectionPointName: widget.collectionPointName,
            ));
          } else if (state is CollectionPointUnlinked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã xóa liên kết loại rác thành công'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Reload data
            context.read<WasteTypeBloc>().add(LoadWasteTypesForCollectionPoint(
              collectionPointId: widget.collectionPointId,
              collectionPointName: widget.collectionPointName,
            ));
          } else if (state is WasteTypeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WasteTypeLoading) {
            return const LoadingView(message: 'Đang tải dữ liệu...');
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab loại rác đã liên kết
              _buildLinkedWasteTypesTab(),

              // Tab loại rác có thể thêm
              _buildAvailableWasteTypesTab(),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildLinkedWasteTypesTab() {
    // Filter linked waste types by search query
    final filteredLinkedTypes = _linkedSearchQuery.isEmpty
        ? _linkedWasteTypes
        : _linkedWasteTypes.where((type) => 
            type.name.toLowerCase().contains(_linkedSearchQuery.toLowerCase()) ||
            type.description.toLowerCase().contains(_linkedSearchQuery.toLowerCase()) ||
            type.category.toLowerCase().contains(_linkedSearchQuery.toLowerCase())
          ).toList();

    if (_linkedWasteTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có loại rác nào được liên kết',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chuyển sang tab "Có thể thêm" để thêm loại rác',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search box
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchField(
            controller: _linkedSearchController,
            hintText: 'Tìm kiếm loại rác đã liên kết...',
            onClear: () {
              _linkedSearchController.clear();
            },
          ),
        ),
        
        // Counter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${filteredLinkedTypes.length} loại rác',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // List of linked waste types
        Expanded(
          child: filteredLinkedTypes.isEmpty && _linkedSearchQuery.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'Không tìm thấy loại rác phù hợp',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLinkedTypes.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final wasteType = filteredLinkedTypes[index];
                    return BlocBuilder<AdminCubit, bool>(
                      builder: (context, isAdmin) {
                        return WasteTypeItem(
                          wasteType: wasteType,
                          actionButtonText: 'Xóa liên kết',
                          actionButtonIcon: Icons.link_off,
                          actionButtonColor: Colors.red,
                          onActionPressed: isAdmin
                            ? () {
                                _showUnlinkConfirmation(
                                  context,
                                  wasteType.id,
                                  wasteType.name,
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Bạn không có quyền thực hiện chức năng này'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildAvailableWasteTypesTab() {
    // Get waste types that are not linked yet
    final availableWasteTypes = _allWasteTypes
        .where((wasteType) => !_linkedWasteTypes.any((linked) => linked.id == wasteType.id))
        .toList();
        
    // Filter available waste types by search query
    final filteredAvailableTypes = _availableSearchQuery.isEmpty
        ? availableWasteTypes
        : availableWasteTypes.where((type) => 
            type.name.toLowerCase().contains(_availableSearchQuery.toLowerCase()) ||
            type.description.toLowerCase().contains(_availableSearchQuery.toLowerCase()) ||
            type.category.toLowerCase().contains(_availableSearchQuery.toLowerCase())
          ).toList();

    if (availableWasteTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tất cả loại rác đã được liên kết',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Điểm thu gom này có thể xử lý tất cả các loại rác trong hệ thống',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search box
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchField(
            controller: _availableSearchController,
            hintText: 'Tìm kiếm loại rác có thể thêm...',
            onClear: () {
              _availableSearchController.clear();
            },
          ),
        ),
        
        // Counter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${filteredAvailableTypes.length} loại rác có thể thêm',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // List of available waste types
        Expanded(
          child: filteredAvailableTypes.isEmpty && _availableSearchQuery.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy loại rác phù hợp',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredAvailableTypes.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final wasteType = filteredAvailableTypes[index];
                    return BlocBuilder<AdminCubit, bool>(
                      builder: (context, isAdmin) {
                        return WasteTypeItem(
                          wasteType: wasteType,
                          actionButtonText: 'Thêm liên kết',
                          actionButtonIcon: Icons.link,
                          actionButtonColor: Colors.blue,
                          onActionPressed: isAdmin 
                              ? () {
                                  context.read<WasteTypeBloc>().add(
                                    AddWasteTypeToCollectionPoint(
                                      collectionPointId: widget.collectionPointId,
                                      wasteTypeId: wasteType.id,
                                    ),
                                  );
                                }
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bạn không có quyền thực hiện chức năng này'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
} 