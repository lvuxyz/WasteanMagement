import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../blocs/map/map_bloc.dart';
import '../blocs/map/map_event.dart';
import '../blocs/map/map_state.dart';
import '../services/mapbox_service.dart';
import '../utils/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? _mapController;
  double _currentZoom = 13.0;
  final String _mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardHeight = screenSize.height * 0.18;
    
    return BlocProvider(
      create: (context) => MapBloc(mapboxService: MapboxService()),
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
                // Mapbox Map - Make sure it fills the entire available space
                Positioned.fill(
                  child: MapWidget(
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
                      
                      // Configure gesture settings with improved responsiveness
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
                      ));
                      
                      context.read<MapBloc>().add(MapInitialized(controller));
                    },
                  ),
                ),

                // Loading indicator - Ensure it's positioned correctly to not block gestures
                if (state.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),

                // Danh sách điểm thu gom - adjusted to not interfere with map gestures
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
    final capacity = point['current_load'] / point['capacity'] * 100;
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
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: capacity > 80
                    ? Colors.red
                    : capacity > 50
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
                  children: [
                    Text(
                      point['name'],
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                            '${point['distance']} km - ${point['address']}',
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
                      'Giờ mở cửa: ${point['operating_hours']}',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const Spacer(),
                    LinearProgressIndicator(
                      value: point['current_load'] / point['capacity'],
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        capacity > 80
                            ? Colors.red
                            : capacity > 50
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
                          '${point['current_load']}/${point['capacity']} kg',
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