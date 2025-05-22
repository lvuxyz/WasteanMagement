import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../blocs/collection_point/collection_point_bloc.dart';
import '../../blocs/collection_point/collection_point_event.dart';
import '../../blocs/collection_point/collection_point_state.dart';
import '../../models/collection_point.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/error_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class CollectionPointDetailsScreen extends StatefulWidget {
  final int collectionPointId;

  const CollectionPointDetailsScreen({
    Key? key,
    required this.collectionPointId,
  }) : super(key: key);

  @override
  State<CollectionPointDetailsScreen> createState() =>
      _CollectionPointDetailsScreenState();
}

class _CollectionPointDetailsScreenState
    extends State<CollectionPointDetailsScreen> {
  late CollectionPointBloc _collectionPointBloc;
  MapboxMap? _mapController;

  @override
  void initState() {
    super.initState();
    _collectionPointBloc = context.read<CollectionPointBloc>();
    _collectionPointBloc.add(LoadCollectionPointDetails(widget.collectionPointId));
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Chi tiết điểm thu gom',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocBuilder<CollectionPointBloc, CollectionPointState>(
        builder: (context, state) {
          if (state is CollectionPointLoading) {
            return const LoadingView(message: 'Đang tải dữ liệu...');
          } else if (state is CollectionPointError) {
            return ErrorView(
              icon: Icons.error_outline,
              title: 'Đã xảy ra lỗi',
              message: state.message,
              buttonText: 'Thử lại',
              onRetry: () => _collectionPointBloc.add(LoadCollectionPointDetails(widget.collectionPointId)),
            );
          } else if (state is CollectionPointDetailsLoaded) {
            return _buildDetailsView(state.collectionPoint);
          }
          return const LoadingView(message: 'Đang tải dữ liệu...');
        },
      ),
    );
  }

  Widget _buildDetailsView(CollectionPoint collectionPoint) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map section
          SizedBox(
            height: 200,
            child: _buildMapView(collectionPoint),
          ),
          
          // Basic information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        collectionPoint.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusBadge(collectionPoint.status),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Address
                _buildInfoRow(
                  Icons.location_on, 
                  collectionPoint.address,
                  onTap: () => _launchMaps(collectionPoint.latitude, collectionPoint.longitude),
                ),
                const SizedBox(height: 8),
                
                // Operating hours
                _buildInfoRow(
                  Icons.access_time, 
                  'Giờ mở cửa: ${collectionPoint.operatingHours}',
                ),
                const SizedBox(height: 8),
                
                // Capacity and current load
                _buildCapacityRow(collectionPoint),
                const SizedBox(height: 16),
                
                // Coordinates
                _buildCoordinatesRow(collectionPoint),
                const SizedBox(height: 24),
                
                // Waste types section
                _buildWasteTypesSection(collectionPoint),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(CollectionPoint collectionPoint) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: MapWidget(
        key: const ValueKey('detailsMapWidget'),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        cameraOptions: CameraOptions(
          center: Point(
            coordinates: Position(
              collectionPoint.longitude,
              collectionPoint.latitude,
            ),
          ),
          zoom: 14.0,
        ),
        onMapCreated: (MapboxMap mapController) {
          _mapController = mapController;
          
          // Disable gestures for better performance
          mapController.gestures.updateSettings(
            GesturesSettings(
              rotateEnabled: false,
              scrollEnabled: false,
              pinchToZoomEnabled: false,
              doubleTapToZoomInEnabled: false,
              doubleTouchToZoomOutEnabled: false,
              quickZoomEnabled: false,
              pitchEnabled: false,
            ),
          );
          
          // Add marker
          _addMarker(
            mapController,
            collectionPoint.latitude, 
            collectionPoint.longitude,
            collectionPoint.name,
          );
        },
      ),
    );
  }
  
  Future<void> _addMarker(
    MapboxMap mapController, 
    double latitude, 
    double longitude,
    String title,
  ) async {
    try {
      final pointAnnotationManager = await mapController.annotations.createPointAnnotationManager();
      
      final options = PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(longitude, latitude),
        ),
        iconSize: 1.0,
        textField: title,
        textSize: 12.0,
        textOffset: [0.0, 1.5],
        textColor: Colors.black.value,
        textHaloWidth: 1.0,
        textHaloColor: Colors.white.value,
      );
      
      await pointAnnotationManager.create(options);
    } catch (e) {
      developer.log('Error adding marker: $e', error: e);
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        text = 'Hoạt động';
        break;
      case 'inactive':
        color = Colors.grey;
        text = 'Không hoạt động';
        break;
      case 'maintenance':
        color = Colors.orange;
        text = 'Bảo trì';
        break;
      default:
        color = Colors.blue;
        text = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: onTap != null ? AppColors.primaryGreen : Colors.black87,
                ),
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.open_in_new,
                size: 16,
                color: AppColors.primaryGreen,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityRow(CollectionPoint collectionPoint) {
    final currentLoad = collectionPoint.currentLoad ?? 0;
    final capacity = collectionPoint.capacity.toDouble();
    final percentage = capacity > 0 ? (currentLoad / capacity * 100).clamp(0.0, 100.0) : 0.0;
    
    Color getCapacityColor(double percentage) {
      if (percentage > 90) return Colors.red;
      if (percentage > 70) return Colors.orange;
      if (percentage > 50) return Colors.amber;
      return AppColors.primaryGreen;
    }
    
    final color = getCapacityColor(percentage);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Công suất: ${currentLoad.toStringAsFixed(0)}/${capacity.toStringAsFixed(0)} kg',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            minHeight: 8,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildCoordinatesRow(CollectionPoint collectionPoint) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vĩ độ (Latitude)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  collectionPoint.latitude.toStringAsFixed(6),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kinh độ (Longitude)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  collectionPoint.longitude.toStringAsFixed(6),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteTypesSection(CollectionPoint collectionPoint) {
    final wasteTypes = collectionPoint.wasteTypes;
    
    if (wasteTypes == null || wasteTypes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Không có thông tin về loại rác được thu gom',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Loại rác được thu gom',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...wasteTypes.map((wasteType) => _buildWasteTypeItem(wasteType)).toList(),
      ],
    );
  }

  Widget _buildWasteTypeItem(WasteType wasteType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: wasteType.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: wasteType.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                wasteType.icon,
                color: wasteType.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  wasteType.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: wasteType.color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: wasteType.recyclable
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  wasteType.recyclable ? 'Tái chế' : 'Không tái chế',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: wasteType.recyclable ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          if (wasteType.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              wasteType.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giá: ${wasteType.unitPrice.toStringAsFixed(0)} VNĐ/${wasteType.unit}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showHandlingInstructions(context, wasteType),
                icon: const Icon(Icons.info_outline, size: 16),
                label: const Text('Hướng dẫn xử lý'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHandlingInstructions(BuildContext context, WasteType wasteType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hướng dẫn xử lý ${wasteType.name}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            wasteType.handlingInstructions,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _launchMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      developer.log('Could not launch maps: $e', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở ứng dụng bản đồ'),
        ),
      );
    }
  }
} 