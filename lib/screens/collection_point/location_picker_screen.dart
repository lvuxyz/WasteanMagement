import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../utils/app_colors.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool _isLoadingAddress = false;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedAddress;
  Point? _centerPoint;

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
    
    // Fetch address for initial coordinates if available
    if (_selectedLatitude != null && _selectedLongitude != null) {
      _fetchAddress(_selectedLatitude!, _selectedLongitude!);
    }
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

      // Create a simple point annotation without iconImage (using default marker)
      final options = PointAnnotationOptions(
        geometry: point,
        iconSize: 1.5,
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
      
      // Update coordinates
      setState(() {
        _selectedLatitude = point.coordinates.lat.toDouble();
        _selectedLongitude = point.coordinates.lng.toDouble();
        _centerPoint = point;
      });
      
      // Fetch address for these coordinates
      await _fetchAddress(_selectedLatitude!, _selectedLongitude!);
      
    } catch (e) {
      developer.log('Error updating map marker: $e', error: e);
    }
  }
  
  Future<void> _fetchAddress(double latitude, double longitude) async {
    setState(() {
      _isLoadingAddress = true;
      _selectedAddress = "Đang tải địa chỉ...";
    });
    
    try {
      // Using OpenStreetMap Nominatim for reverse geocoding (free and open source)
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json&accept-language=vi'
        ),
        headers: {
          'User-Agent': 'WasteManagementApp/1.0',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] as String?;
        
        setState(() {
          _selectedAddress = address ?? "Không thể xác định địa chỉ";
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _selectedAddress = "Không thể xác định địa chỉ";
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      developer.log('Error fetching address: $e', error: e);
      setState(() {
        _selectedAddress = "Không thể xác định địa chỉ";
        _isLoadingAddress = false;
      });
    }
  }
  
  Future<Point?> _getCurrentCenterPoint() async {
    if (_mapController == null) return null;
    
    try {
      // Get the current center of the map
      CameraState cameraState = await _mapController!.getCameraState();
      return cameraState.center;
    } catch (e) {
      developer.log('Error getting center point: $e', error: e);
      return null;
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
          
          // Center crosshair - always visible for positioning
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.red,
                  size: 36,
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (!_hasSelectedLocation) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Di chuyển bản đồ để chọn vị trí',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
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
                        'Vị trí điểm thu gom',
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
                    // Address section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.home,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Địa chỉ:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              if (_isLoadingAddress)
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Text(
                              _selectedAddress ?? 'Không xác định',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Coordinates
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
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
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
                  ] else
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Di chuyển bản đồ để điểm chính giữa là vị trí bạn muốn chọn',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _selectCenterLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
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
                                Icons.location_on,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'CHỌN VỊ TRÍ NÀY',
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
      Point? centerPoint = await _getCurrentCenterPoint();
      if (centerPoint != null) {
        await _updateMapMarker(centerPoint);
      }
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