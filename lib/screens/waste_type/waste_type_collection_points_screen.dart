import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../models/collection_point_model.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_tab_bar.dart';
import '../../widgets/common/search_field.dart';
import '../../widgets/collection_point/collection_point_item.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/confirmation_dialog.dart';

class WasteTypeCollectionPointsScreen extends StatefulWidget {
  final int wasteTypeId;

  const WasteTypeCollectionPointsScreen({
    Key? key,
    required this.wasteTypeId,
  }) : super(key: key);

  @override
  State<WasteTypeCollectionPointsScreen> createState() => _WasteTypeCollectionPointsScreenState();
}

class _WasteTypeCollectionPointsScreenState extends State<WasteTypeCollectionPointsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _linkedSearchController = TextEditingController();
  final TextEditingController _availableSearchController = TextEditingController();
  String _linkedSearchQuery = '';
  String _availableSearchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _linkedSearchController.addListener(_onLinkedSearchChanged);
    _availableSearchController.addListener(_onAvailableSearchChanged);
    
    // Load waste type details with collection points
    context.read<WasteTypeBloc>().add(LoadWasteTypeDetailsWithAvailablePoints(widget.wasteTypeId));
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
  
  void _showUnlinkConfirmation(BuildContext context, int collectionPointId, String name) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Xóa liên kết',
        content: 'Bạn có chắc chắn muốn xóa liên kết với điểm thu gom "$name" không?',
        confirmText: 'Xóa liên kết',
        cancelText: 'Hủy',
        onConfirm: () {
          Navigator.of(context).pop();
          context.read<WasteTypeBloc>().add(
            UnlinkCollectionPoint(
              wasteTypeId: widget.wasteTypeId,
              collectionPointId: collectionPointId,
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
        title: BlocBuilder<WasteTypeBloc, WasteTypeState>(
          builder: (context, state) {
            if (state is WasteTypeDetailLoaded) {
              return Text(
                'Quản lý điểm thu gom: ${state.wasteType.name}',
                style: TextStyle(color: Colors.white),
              );
            }
            return Text(
              'Quản lý điểm thu gom',
              style: TextStyle(color: Colors.white),
            );
          },
        ),
        bottom: CustomTabBar(
          controller: _tabController,
          backgroundColor: AppColors.primaryGreen,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Đã liên kết'),
            Tab(text: 'Sẵn có'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<WasteTypeBloc>().add(
                LoadWasteTypeDetailsWithAvailablePoints(widget.wasteTypeId)
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<WasteTypeBloc, WasteTypeState>(
        listener: (context, state) {
          if (state is CollectionPointLinked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã thêm điểm thu gom thành công'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Reload to get updated list
            context.read<WasteTypeBloc>().add(
              LoadWasteTypeDetailsWithAvailablePoints(widget.wasteTypeId)
            );
          } else if (state is CollectionPointUnlinked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã xóa liên kết điểm thu gom thành công'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Reload to get updated list
            context.read<WasteTypeBloc>().add(
              LoadWasteTypeDetailsWithAvailablePoints(widget.wasteTypeId)
            );
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
            return LoadingView(message: 'Đang tải điểm thu gom...');
          }

          if (state is WasteTypeDetailLoaded) {
            final wasteType = state.wasteType;
            final linkedCollectionPoints = state.collectionPoints;
            final allCollectionPoints = state.allCollectionPoints ?? [];

            // Filter out already linked collection points
            final availableCollectionPoints = allCollectionPoints
                .where((cp) => !linkedCollectionPoints.any((lcp) => lcp.id == cp.id))
                .toList();
                
            // Filter linked points by search query
            final filteredLinkedPoints = _linkedSearchQuery.isEmpty
                ? linkedCollectionPoints
                : linkedCollectionPoints.where((cp) => 
                    cp.name.toLowerCase().contains(_linkedSearchQuery.toLowerCase()) ||
                    cp.address.toLowerCase().contains(_linkedSearchQuery.toLowerCase())
                  ).toList();
                  
            // Filter available points by search query
            final filteredAvailablePoints = _availableSearchQuery.isEmpty
                ? availableCollectionPoints
                : availableCollectionPoints.where((cp) => 
                    cp.name.toLowerCase().contains(_availableSearchQuery.toLowerCase()) ||
                    cp.address.toLowerCase().contains(_availableSearchQuery.toLowerCase())
                  ).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                // Tab Điểm thu gom đã liên kết
                _buildLinkedCollectionPointsTab(filteredLinkedPoints, wasteType),

                // Tab Điểm thu gom sẵn có
                _buildAvailableCollectionPointsTab(filteredAvailablePoints, wasteType),
              ],
            );
          }

          if (state is WasteTypeError) {
            return ErrorView(
              icon: Icons.error_outline,
              title: 'Đã xảy ra lỗi',
              message: state.message,
              buttonText: 'Thử lại',
              onRetry: () {
                context.read<WasteTypeBloc>().add(
                  LoadWasteTypeDetailsWithAvailablePoints(widget.wasteTypeId),
                );
              },
            );
          }

          return Center(
            child: Text('Không tìm thấy dữ liệu'),
          );
        },
      ),
    );
  }
  
  Widget _buildLinkedCollectionPointsTab(List<CollectionPoint> collectionPoints, WasteType wasteType) {
    if (collectionPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_off,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có điểm thu gom nào được liên kết',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Chuyển sang tab "Sẵn có" để thêm điểm thu gom mới',
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
            hintText: 'Tìm kiếm điểm thu gom đã liên kết...',
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
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${collectionPoints.length} điểm thu gom',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // List of linked collection points
        Expanded(
          child: collectionPoints.isEmpty && _linkedSearchQuery.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'Không tìm thấy điểm thu gom phù hợp',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: collectionPoints.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final collectionPoint = collectionPoints[index];
                    return CollectionPointItem(
                      collectionPoint: collectionPoint,
                      actionButtonText: 'Xóa liên kết',
                      actionButtonIcon: Icons.link_off,
                      actionButtonColor: Colors.red,
                      onActionPressed: () {
                        _showUnlinkConfirmation(
                          context,
                          collectionPoint.id,
                          collectionPoint.name,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildAvailableCollectionPointsTab(List<CollectionPoint> collectionPoints, WasteType wasteType) {
    if (collectionPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Không có điểm thu gom nào khả dụng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tất cả điểm thu gom đã được liên kết hoặc\nchưa có điểm thu gom nào trong hệ thống',
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
            hintText: 'Tìm kiếm điểm thu gom sẵn có...',
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
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${collectionPoints.length} điểm thu gom sẵn có',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // List of available collection points
        Expanded(
          child: collectionPoints.isEmpty && _availableSearchQuery.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'Không tìm thấy điểm thu gom phù hợp',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: collectionPoints.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final collectionPoint = collectionPoints[index];
                    return CollectionPointItem(
                      collectionPoint: collectionPoint,
                      actionButtonText: 'Thêm liên kết',
                      actionButtonIcon: Icons.link,
                      actionButtonColor: Colors.blue,
                      onActionPressed: () {
                        context.read<WasteTypeBloc>().add(
                          LinkCollectionPoint(
                            wasteTypeId: widget.wasteTypeId,
                            collectionPointId: collectionPoint.id,
                          ),
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