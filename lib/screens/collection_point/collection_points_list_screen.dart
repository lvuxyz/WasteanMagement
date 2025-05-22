import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/collection_point.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/search_field.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/error_view.dart';
import '../../repositories/collection_point_repository.dart';
import '../../core/api/api_client.dart';
import '../../blocs/admin/admin_cubit.dart';
import '../../blocs/collection_point/collection_point_bloc.dart';
import '../../blocs/collection_point/collection_point_event.dart';
import '../../blocs/collection_point/collection_point_state.dart';

class CollectionPointsListScreen extends StatefulWidget {
  const CollectionPointsListScreen({Key? key}) : super(key: key);

  @override
  State<CollectionPointsListScreen> createState() => _CollectionPointsListScreenState();
}

class _CollectionPointsListScreenState extends State<CollectionPointsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<CollectionPoint> _collectionPoints = [];
  bool _isLoading = true;
  String? _errorMessage;
  late CollectionPointRepository _repository;
  late CollectionPointBloc _collectionPointBloc;
  
  bool get _isAdmin => context.read<AdminCubit>().state;

  @override
  void initState() {
    super.initState();
    // Lấy ApiClient từ context
    final apiClient = context.read<ApiClient>();
    // Khởi tạo repository
    _repository = CollectionPointRepository(apiClient: apiClient);
    _collectionPointBloc = CollectionPointBloc(repository: _repository);
    _searchController.addListener(_onSearchChanged);
    
    // Load data through BLoC
    _collectionPointBloc.add(LoadCollectionPoints());
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _collectionPointBloc.close();
    super.dispose();
  }

  void _onSearchChanged() {
    _collectionPointBloc.add(SearchCollectionPoints(_searchController.text));
  }

  void _navigateToWasteTypes(BuildContext context, CollectionPoint collectionPoint) {
    Navigator.pushNamed(
      context,
      '/collection-point/waste-types',
      arguments: {
        'collectionPointId': collectionPoint.collectionPointId,
        'collectionPointName': collectionPoint.name,
      },
    );
  }
  
  void _navigateToCreateScreen() {
    Navigator.pushNamed(
      context,
      '/collection-points/create',
    ).then((_) {
      // Refresh data when returning from create screen
      _collectionPointBloc.add(LoadCollectionPoints());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _collectionPointBloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          title: Text(
            'Điểm thu gom',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _collectionPointBloc.add(LoadCollectionPoints()),
            ),
          ],
        ),
        body: BlocConsumer<CollectionPointBloc, CollectionPointState>(
          listener: (context, state) {
            if (state is CollectionPointError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CollectionPointLoading) {
              return LoadingView(message: 'Đang tải điểm thu gom...');
            } else if (state is CollectionPointError) {
              return ErrorView(
                icon: Icons.error_outline,
                title: 'Đã xảy ra lỗi',
                message: state.message,
                buttonText: 'Thử lại',
                onRetry: () => _collectionPointBloc.add(LoadCollectionPoints()),
              );
            } else if (state is CollectionPointsLoaded) {
              return _buildCollectionPointsList(state);
            }
            
            return const LoadingView(message: 'Đang tải...');
          },
        ),
        floatingActionButton: _isAdmin 
          ? FloatingActionButton(
              onPressed: _navigateToCreateScreen,
              backgroundColor: AppColors.primaryGreen,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      ),
    );
  }

  Widget _buildCollectionPointsList(CollectionPointsLoaded state) {
    final filteredCollectionPoints = state.filteredCollectionPoints;

    if (state.collectionPoints.isEmpty) {
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
              'Không có điểm thu gom nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            if (_isAdmin) ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _navigateToCreateScreen,
                icon: Icon(Icons.add),
                label: Text('Tạo điểm thu gom mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
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
            controller: _searchController,
            hintText: 'Tìm kiếm điểm thu gom...',
            onClear: () {
              _searchController.clear();
            },
          ),
        ),
        
        // Counter and Add button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${filteredCollectionPoints.length} điểm thu gom',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_isAdmin)
                TextButton.icon(
                  onPressed: _navigateToCreateScreen,
                  icon: Icon(Icons.add, size: 18),
                  label: Text('Thêm mới'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                  ),
                ),
            ],
          ),
        ),
        
        // List of collection points
        Expanded(
          child: filteredCollectionPoints.isEmpty && state.searchQuery.isNotEmpty
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
                  itemCount: filteredCollectionPoints.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final collectionPoint = filteredCollectionPoints[index];
                    return _buildCollectionPointItem(context, collectionPoint);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCollectionPointItem(BuildContext context, CollectionPoint collectionPoint) {
    // Use currentLoad with a fallback to 0 if it's null
    final currentLoad = collectionPoint.currentLoad ?? 0;
    final capacityPercentage = 
        collectionPoint.capacity > 0
          ? ((currentLoad / collectionPoint.capacity) * 100).clamp(0.0, 100.0).toInt()
          : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor(collectionPoint.status).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header with name and status
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(collectionPoint.status).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(collectionPoint.status),
                      color: _getStatusColor(collectionPoint.status),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collectionPoint.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          collectionPoint.address,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(collectionPoint.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(collectionPoint.status).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(collectionPoint.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(collectionPoint.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Info row (hours, capacity)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  // Hours
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.access_time_outlined,
                            color: Colors.orange,
                            size: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            collectionPoint.operatingHours,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Capacity
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCapacityColor(capacityPercentage).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getCapacityColor(capacityPercentage).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$capacityPercentage% đầy',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getCapacityColor(capacityPercentage),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // View waste types button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: BlocBuilder<AdminCubit, bool>(
                builder: (context, isAdmin) {
                  return TextButton.icon(
                    onPressed: () => _navigateToWasteTypes(context, collectionPoint),
                    icon: Icon(
                      isAdmin ? Icons.edit : Icons.recycling,
                      size: 16,
                      color: isAdmin ? AppColors.primaryGreen : Colors.blue,
                    ),
                    label: Text(
                      isAdmin ? 'Quản lý loại rác thu gom' : 'Xem loại rác được thu gom',
                      style: TextStyle(
                        color: isAdmin ? AppColors.primaryGreen : Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCapacityColor(int percentage) {
    if (percentage > 90) {
      return Colors.red;
    } else if (percentage > 70) {
      return Colors.orange;
    } else if (percentage > 40) {
      return Colors.amber;
    } else {
      return AppColors.primaryGreen;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.primaryGreen;
      case 'inactive':
        return Colors.grey;
      case 'full':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle_outline;
      case 'inactive':
        return Icons.pause_circle_outline;
      case 'full':
        return Icons.warning_amber_outlined;
      case 'maintenance':
        return Icons.build_outlined;
      default:
        return Icons.info_outline;
    }
  }
  
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Hoạt động';
      case 'inactive':
        return 'Tạm dừng';
      case 'full':
        return 'Đầy';
      case 'maintenance':
        return 'Bảo trì';
      default:
        return status;
    }
  }
} 