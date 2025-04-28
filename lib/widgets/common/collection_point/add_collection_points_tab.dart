// widgets/collection_point/add_collection_points_tab.dart
import 'package:flutter/material.dart';
import '../../../models/collection_point_model.dart';
import '../../../utils/app_colors.dart';
import '../search_field.dart';

class AddCollectionPointsTab extends StatefulWidget {
  final List<CollectionPoint> availableCollectionPoints;
  final Function(CollectionPoint) onAddCollectionPoint;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const AddCollectionPointsTab({
    Key? key,
    required this.availableCollectionPoints,
    required this.onAddCollectionPoint,
    required this.searchQuery,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  State<AddCollectionPointsTab> createState() => _AddCollectionPointsTabState();
}

class _AddCollectionPointsTabState extends State<AddCollectionPointsTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search box
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchField(
            hintText: 'Tìm kiếm điểm thu gom...',
            onChanged: widget.onSearchChanged,
            value: widget.searchQuery,
          ),
        ),
        
        // List of collection points
        Expanded(
          child: widget.availableCollectionPoints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'Không tìm thấy điểm thu gom',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: widget.availableCollectionPoints.length,
                  padding: EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final collectionPoint = widget.availableCollectionPoints[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          collectionPoint?.name ?? 'Unknown',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          collectionPoint?.address ?? 'No address',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: () => widget.onAddCollectionPoint(collectionPoint),
                          icon: Icon(Icons.add, size: 18),
                          label: Text('Thêm'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}