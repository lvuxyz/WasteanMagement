// widgets/collection_point/add_collection_points_tab.dart
import 'package:flutter/material.dart';
import 'package:wasteanmagement/utils/app_colors.dart';
import 'package:wasteanmagement/widgets/common/search_field.dart';
import '../../models/collection_point_model.dart';
import '../../utils/app_colors.dart';
import '../common/search_field.dart';

class AddCollectionPointsTab extends StatefulWidget {
  final int wasteTypeId;
  final List<CollectionPoint> availableCollectionPoints;
  final Function(int) onLinkCollectionPoint;

  const AddCollectionPointsTab({
    Key? key,
    required this.wasteTypeId,
    required this.availableCollectionPoints,
    required this.onLinkCollectionPoint,
  }) : super(key: key);

  @override
  State<AddCollectionPointsTab> createState() => _AddCollectionPointsTabState();
}

class _AddCollectionPointsTabState extends State<AddCollectionPointsTab> {
  final TextEditingController _searchController = TextEditingController();
  List<CollectionPoint> _filteredCollectionPoints = [];

  @override
  void initState() {
    super.initState();
    _filteredCollectionPoints = widget.availableCollectionPoints;
    _searchController.addListener(_filterCollectionPoints);
  }

  @override
  void didUpdateWidget(AddCollectionPointsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update filtered list when available collection points change
    if (widget.availableCollectionPoints != oldWidget.availableCollectionPoints) {
      _filterCollectionPoints();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCollectionPoints() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCollectionPoints = widget.availableCollectionPoints;
      } else {
        _filteredCollectionPoints = widget.availableCollectionPoints
            .where((cp) =>
        cp.name.toLowerCase().contains(query) ||
            cp.address.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
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

        // Filter info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Hiển thị ${_filteredCollectionPoints.length} điểm thu gom có thể liên kết',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Divider
        Divider(color: Colors.grey[300]),

        // List of collection points
        Expanded(
          child: _buildCollectionPointsList(),
        ),
      ],
    );
  }

  Widget _buildCollectionPointsList() {
    if (widget.availableCollectionPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tất cả điểm thu gom đã được liên kết',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredCollectionPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy điểm thu gom phù hợp',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCollectionPoints.length,
      separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
      itemBuilder: (context, index) {
        final collectionPoint = _filteredCollectionPoints[index];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.location_on,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
          ),
          title: Text(
            collectionPoint.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                collectionPoint.address,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    collectionPoint.operating_hours,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.dashboard,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${collectionPoint.current_load}/${collectionPoint.capacity} kg',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () {
              widget.onLinkCollectionPoint(collectionPoint.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            child: const Text('Liên kết'),
          ),
        );
      },
    );
  }
}