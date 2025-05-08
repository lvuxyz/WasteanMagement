import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/collection_point.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/search_field.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/error_view.dart';
import '../../repositories/collection_point_repository.dart';
import '../../core/api/api_client.dart';

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

  @override
  void initState() {
    super.initState();
    // Lấy ApiClient từ context
    final apiClient = context.read<ApiClient>();
    // Khởi tạo repository
    _repository = CollectionPointRepository(apiClient: apiClient);
    _searchController.addListener(_onSearchChanged);
    _loadCollectionPoints();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<void> _loadCollectionPoints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Lấy dữ liệu từ API thông qua repository
      final collectionPoints = await _repository.getAllCollectionPoints();
      
      setState(() {
        _collectionPoints = collectionPoints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          'Điểm thu gom',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCollectionPoints,
          ),
        ],
      ),
      body: _isLoading
          ? LoadingView(message: 'Đang tải điểm thu gom...')
          : _errorMessage != null
              ? ErrorView(
                  icon: Icons.error_outline,
                  title: 'Đã xảy ra lỗi',
                  message: _errorMessage!,
                  buttonText: 'Thử lại',
                  onRetry: _loadCollectionPoints,
                )
              : _buildCollectionPointsList(),
    );
  }

  Widget _buildCollectionPointsList() {
    // Filter collection points by search query
    final filteredCollectionPoints = _searchQuery.isEmpty
        ? _collectionPoints
        : _collectionPoints.where((cp) => 
            cp.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            cp.address.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

    if (_collectionPoints.isEmpty) {
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
                  '${filteredCollectionPoints.length} điểm thu gom',
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
        
        // List of collection points
        Expanded(
          child: filteredCollectionPoints.isEmpty && _searchQuery.isNotEmpty
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
        ((currentLoad / collectionPoint.capacity) * 100).toInt();

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
              child: TextButton.icon(
                onPressed: () => _navigateToWasteTypes(context, collectionPoint),
                icon: Icon(
                  Icons.recycling,
                  size: 16,
                  color: Colors.blue,
                ),
                label: Text(
                  'Xem loại rác được thu gom',
                  style: TextStyle(
                    color: Colors.blue,
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