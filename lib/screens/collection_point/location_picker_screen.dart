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
  double _currentZoom = 14.0;
  bool _isLoading = false;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedAddress;

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

      // Create a simple point annotation
      final options = PointAnnotationOptions(
        geometry: point,
        iconSize: 1.5,
        iconOffset: [0.0, -10.0],
        symbolSortKey: 10.0,
        textField: "Vị trí được chọn",
        textSize: 12.0,
        textOffset: [0.0, 2.0],
        textColor: Colors.black.value,
        textAnchor: TextAnchor.TOP,
        textHaloWidth: 1.0,
        textHaloColor: Colors.white.value,
      );

      // Create the annotation
      await _pointAnnotationManager!.create(options);

      // Center the map on the selected point
      await _mapController!.flyTo(
        CameraOptions(
          center: point,
          zoom: _currentZoom,
        ),
        MapAnimationOptions(duration: 300, startDelay: 0),
      );
      
      // Update coordinates
      setState(() {
        _selectedLatitude = point.coordinates.lat.toDouble();
        _selectedLongitude = point.coordinates.lng.toDouble();
        _selectedAddress = "Vị trí đã chọn";
      });
      
    } catch (e) {
      developer.log('Error updating map marker: $e', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
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
            width: screenSize.width,
            height: screenSize.height,
            child: Builder(
              builder: (context) {
                try {
                  return MapWidget(
                    key: const ValueKey('mapWidget'),
                    styleUri: MapboxStyles.MAPBOX_STREETS,
                    cameraOptions: CameraOptions(
                      center: Point(
                        coordinates: Position(
                          widget.initialLongitude ?? _defaultLongitude,
                          widget.initialLatitude ?? _defaultLatitude,
                        ),
                      ),
                      zoom: _currentZoom,
                    ),
                    onMapCreated: _onMapCreated,
                  );
                } catch (e) {
                  developer.log('Error creating MapWidget: $e', error: e);
                  return _buildErrorWidget();
                }
              },
            ),
          ),
          
          // Target crosshair in the center for easier alignment
          if (!_hasSelectedLocation) Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primaryGreen,
                  size: 36,
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGreen,
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Nhấn vào bản đồ để chọn vị trí',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ),
            
          // Map controls for zoom
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoomIn",
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: AppColors.primaryGreen),
                  onPressed: () {
                    if (_mapController != null) {
                      _currentZoom += 1;
                      _mapController!.setCamera(
                        CameraOptions(
                          zoom: _currentZoom,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "zoomOut",
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: AppColors.primaryGreen),
                  onPressed: () {
                    if (_mapController != null) {
                      _currentZoom -= 1;
                      _mapController!.setCamera(
                        CameraOptions(
                          zoom: _currentZoom,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
            
          // Location selection button
          Positioned(
            left: 16,
            bottom: 100,
            child: FloatingActionButton(
              backgroundColor: AppColors.primaryGreen,
              child: const Icon(Icons.my_location, color: Colors.white),
              onPressed: _selectCenterLocation,
            ),
          ),
            
          // Bottom info panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Vị trí đã chọn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      if (_hasSelectedLocation)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'Đã chọn',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_hasSelectedLocation) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.pin_drop,
                          color: Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _selectedAddress ?? 'Vị trí không xác định',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
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
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedLatitude!.toStringAsFixed(6),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedLongitude!.toStringAsFixed(6),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Nhấn nút vị trí để chọn điểm trên bản đồ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _hasSelectedLocation ? _confirmLocation : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'XÁC NHẬN VỊ TRÍ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
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
  
  void _selectCenterLocation() async {
    if (_mapController == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get the current center of the map
      CameraState cameraState = await _mapController!.getCameraState();
      Point centerPoint = cameraState.center;
      
      await _updateMapMarker(centerPoint);
    } catch (e) {
      developer.log('Error selecting center location: $e', error: e);
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
    _currentZoom = 14.0;
    
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
          address: _selectedAddress,
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