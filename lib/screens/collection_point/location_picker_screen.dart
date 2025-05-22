import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../utils/app_colors.dart';
import 'dart:developer' as developer;

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

class LocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
  }) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  MapboxMap? _mapController;
  PointAnnotationManager? _pointAnnotationManager;
  double _currentZoom = 13.0;
  bool _isLoading = false;
  double? _selectedLatitude;
  double? _selectedLongitude;

  // Default to Ho Chi Minh City if no initial location
  final double _defaultLatitude = 10.7731;
  final double _defaultLongitude = 106.6880;

  @override
  void initState() {
    super.initState();
    // Set orientation for better experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Initialize with provided coordinates if available
    _selectedLatitude = widget.initialLatitude;
    _selectedLongitude = widget.initialLongitude;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _updateMapMarker(Point point) async {
    if (_pointAnnotationManager == null || _mapController == null) {
      return;
    }

    try {
      // Clear existing annotations
      await _pointAnnotationManager!.deleteAll();

      // Create a new point annotation
      final options = PointAnnotationOptions(
        geometry: point,
        iconSize: 1.0,
        iconOffset: [0.0, -20.0],
        symbolSortKey: 10.0,
        textColor: Colors.red.value,
        textOffset: [0.0, -2.0],
        textAnchor: TextAnchor.TOP,
        textSize: 16.0,
      );

      // Create the annotation
      await _pointAnnotationManager!.create(options);

      // Center the map on the selected point
      await _mapController!.flyTo(
        CameraOptions(
          center: point,
          zoom: _currentZoom,
        ),
        MapAnimationOptions(duration: 500, startDelay: 0),
      );
    } catch (e) {
      developer.log('Error updating map marker: $e', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Chọn vị trí điểm thu gom',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _hasSelectedLocation ? _confirmLocation : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map Widget
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Builder(
              builder: (context) {
                try {
                  return GestureDetector(
                    onTapUp: (details) => _handleTap(details.localPosition),
                    child: MapWidget(
                      key: const ValueKey('mapWidget'),
                      styleUri: MapboxStyles.MAPBOX_STREETS,
                      cameraOptions: CameraOptions(
                        center: Point(
                          coordinates: Position(
                            widget.initialLongitude ?? _defaultLongitude,
                            widget.initialLatitude ?? _defaultLatitude,
                          ),
                        ),
                        zoom: 13.0,
                      ),
                      onMapCreated: _onMapCreated,
                    ),
                  );
                } catch (e) {
                  developer.log('Error creating MapWidget: $e', error: e);
                  return _buildErrorWidget();
                }
              },
            ),
          ),
          
          // Center indicator
          Center(
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGreen,
                  width: 2,
                ),
              ),
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
            
          // Bottom info panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Vị trí đã chọn:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_hasSelectedLocation) ...[
                    Text(
                      'Vĩ độ: ${_selectedLatitude!.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Kinh độ: ${_selectedLongitude!.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ] else
                    Text(
                      'Nhấn vào bản đồ để chọn vị trí',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _hasSelectedLocation ? _confirmLocation : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'XÁC NHẬN VỊ TRÍ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleTap(Offset position) async {
    if (_mapController == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Convert screen position to map coordinates
      final screenCoordinate = ScreenCoordinate(x: position.dx, y: position.dy);
      final point = await _mapController!.coordinateForPixel(screenCoordinate);
      
      if (point != null) {
        setState(() {
          _selectedLatitude = point.coordinates.lat.toDouble();
          _selectedLongitude = point.coordinates.lng.toDouble();
        });
        await _updateMapMarker(point);
      }
    } catch (e) {
      developer.log('Error handling tap: $e', error: e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  bool get _hasSelectedLocation => _selectedLatitude != null && _selectedLongitude != null;

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapController = mapboxMap;
    
    // Set initial zoom
    _currentZoom = 13.0;
    
    // Configure gestures
    await mapboxMap.gestures.updateSettings(
      GesturesSettings(
        rotateEnabled: true,
        scrollEnabled: true,
        scrollMode: ScrollMode.HORIZONTAL_AND_VERTICAL,
        pinchToZoomEnabled: true,
        doubleTapToZoomInEnabled: true,
        doubleTouchToZoomOutEnabled: true,
        quickZoomEnabled: true,
        pitchEnabled: true,
      ),
    );
    
    // Create annotation manager for markers
    _pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    
    // If initial location was provided, place a marker
    if (_selectedLatitude != null && _selectedLongitude != null) {
      final point = Point(
        coordinates: Position(
          _selectedLongitude!,
          _selectedLatitude!,
        ),
      );
      await _updateMapMarker(point);
    }
  }

  void _confirmLocation() {
    if (_selectedLatitude != null && _selectedLongitude != null) {
      // Return the selected location to the calling screen
      Navigator.of(context).pop(
        LocationData(
          latitude: _selectedLatitude!,
          longitude: _selectedLongitude!,
        ),
      );
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.map_outlined,
              color: AppColors.primaryGreen,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải bản đồ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng thử lại sau',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
} 