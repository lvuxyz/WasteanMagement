import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../blocs/map/map_bloc.dart';
import '../blocs/map/map_event.dart';
import '../blocs/map/map_state.dart';
import '../services/mapbox_service.dart';
import '../utils/app_colors.dart';
import '../repositories/collection_point_repository.dart';
import '../core/api/api_client.dart';
import '../utils/secure_storage.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? _mapController;
  double _currentZoom = 13.0;

  @override
  void initState() {
    super.initState();
    // Đặt orientation để trải nghiệm được tốt hơn
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // MapBox initialization is handled later when the widget is built
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardHeight = screenSize.height * 0.18;
    
    return BlocProvider(
      create: (context) => MapBloc(
        mapboxService: MapboxService(),
        collectionPointRepository: CollectionPointRepository(
          apiClient: ApiClient(
            client: http.Client(),
            secureStorage: SecureStorage(),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          title: const Text(
            'Điểm Thu Gom Rác',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                if (_mapController != null) {
                  context.read<MapBloc>().add(LoadCollectionPoints());
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.my_location, color: Colors.white),
              onPressed: () {
                if (_mapController != null) {
                  context.read<MapBloc>().add(LoadUserLocation());
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<MapBloc, MapState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                // Đảm bảo map có thể nhận các sự kiện cảm ứng
                Stack(
                  children: [
                    // Mapbox Map
                    SizedBox(
                      width: screenSize.width,
                      height: screenSize.height,
                      child: Builder(
                        builder: (context) {
                          try {
                            return FutureBuilder<bool>(
                              // Delay initialization slightly to allow resources to load
                              future: Future.delayed(const Duration(milliseconds: 500), () => true),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                
                                return MapWidget(
                                  key: const ValueKey('mapWidget'),
                                  styleUri: MapboxStyles.MAPBOX_STREETS,
                                  cameraOptions: CameraOptions(
                                    center: Point(
                                      coordinates: Position(106.6880, 10.7731), // TP.HCM
                                    ),
                                    zoom: 13.0,
                                  ),
                                  onMapCreated: (MapboxMap controller) {
                                    setState(() {
                                      _mapController = controller;
                                      _currentZoom = 13.0;
                                    });
                                    
                                    // Configure gesture settings after a small delay to ensure map is ready
                                    Future.delayed(const Duration(milliseconds: 300), () {
                                      try {
                                        controller.gestures.updateSettings(GesturesSettings(
                                          rotateEnabled: true,
                                          scrollEnabled: true,
                                          scrollMode: ScrollMode.HORIZONTAL_AND_VERTICAL,
                                          pinchToZoomEnabled: true,
                                          doubleTapToZoomInEnabled: true,
                                          doubleTouchToZoomOutEnabled: true,
                                          quickZoomEnabled: true,
                                          simultaneousRotateAndPinchToZoomEnabled: true,
                                          pitchEnabled: true,
                                          scrollDecelerationEnabled: true,
                                          increaseRotateThresholdWhenPinchingToZoom: true,
                                          increasePinchToZoomThresholdWhenRotating: true,
                                        ));
                                      } catch (e) {
                                        print('Error updating gesture settings: $e');
                                      }
                                      
                                      context.read<MapBloc>().add(MapInitialized(controller));
                                    });
                                  },
                                );
                              }
                            );
                          } catch (e) {
                            print('Error creating MapWidget: $e');
                            // Fallback widget when MapBox fails to load
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
                                        setState(() {});  // Force rebuild
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryGreen,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Tải lại'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                // Loading indicator - Đảm bảo không chặn gestures
                if (state.isLoading)
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

                // Danh sách điểm thu gom
                if (state.collectionPoints.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    height: cardHeight,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: state.collectionPoints.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final point = state.collectionPoints[index];
                        return _buildCollectionPointCard(
                          context,
                          point,
                          isSelected: state.selectedPointId == point['id'],
                          cardWidth: screenSize.width * 0.85,
                        );
                      },
                    ),
                  ),
                  
                // Map controls for additional zoom control
                Positioned(
                  right: 16,
                  bottom: state.collectionPoints.isNotEmpty 
                      ? cardHeight + 32 
                      : 16,
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
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryGreen,
          child: const Icon(Icons.directions),
          onPressed: () {
            _showDirectionsNotImplemented(context);
          },
        ),
      ),
    );
  }

  Widget _buildCollectionPointCard(
      BuildContext context,
      Map<String, dynamic> point,
      {bool isSelected = false, double cardWidth = 280}
      ) {
    // Prevent division by zero or invalid values
    final double currentLoad = point['current_load'] is num ? point['current_load'].toDouble() : 0.0;
    final double capacity = point['capacity'] is num && point['capacity'] > 0 
        ? point['capacity'].toDouble() 
        : 1.0;  // Default to 1 to prevent division by zero
        
    final double progressValue = currentLoad / capacity;
    // Ensure the progress value is between 0.0 and 1.0
    final double safeProgressValue = progressValue.isFinite ? progressValue.clamp(0.0, 1.0) : 0.0;
    
    // Calculate capacity percentage for color
    final double capacityPercentage = progressValue * 100;
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width < 360 ? 10.0 : 12.0;
    final titleSize = screenSize.width < 360 ? 14.0 : 16.0;

    return GestureDetector(
      onTap: () {
        context.read<MapBloc>().add(SelectCollectionPoint(point['id']));
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primaryGreen, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: capacityPercentage > 80
                    ? Colors.red
                    : capacityPercentage > 50
                    ? Colors.orange
                    : AppColors.primaryGreen,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      point['name'] ?? 'Điểm thu gom',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.textGrey,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${point['distance']} km - ${point['address'] ?? ''}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: fontSize,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Giờ mở cửa: ${point['operating_hours'] ?? ''}',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: AppColors.textGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    LinearProgressIndicator(
                      value: safeProgressValue,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        capacityPercentage > 80
                            ? Colors.red
                            : capacityPercentage > 50
                            ? Colors.orange
                            : AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Công suất:',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${currentLoad.toStringAsFixed(0)}/${capacity.toStringAsFixed(0)} kg',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  void _showDirectionsNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng chỉ đường sẽ được triển khai trong phiên bản sau.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}