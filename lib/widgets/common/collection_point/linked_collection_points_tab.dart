// widgets/collection_point/linked_collection_points_tab.dart
import 'package:flutter/material.dart';
import '../../../models/collection_point_model.dart';

class LinkedCollectionPointsTab extends StatelessWidget {
  final List<CollectionPoint> linkedCollectionPoints;
  final Function(CollectionPoint) onRemoveCollectionPoint;

  const LinkedCollectionPointsTab({
    Key? key,
    required this.linkedCollectionPoints,
    required this.onRemoveCollectionPoint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return linkedCollectionPoints.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link_off, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Chưa có điểm thu gom nào được liên kết',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: linkedCollectionPoints.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final collectionPoint = linkedCollectionPoints[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    collectionPoint.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    collectionPoint.address,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () => onRemoveCollectionPoint(collectionPoint),
                    icon: Icon(Icons.link_off, size: 18),
                    label: Text('Xóa liên kết'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              );
            },
          );
  }
}