import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxService {
  final String _accessToken;

  MapboxService() : _accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  // Lấy vị trí hiện tại của người dùng
  Future<LocationData?> getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Kiểm tra dịch vụ vị trí có được bật không
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Kiểm tra quyền truy cập vị trí
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  // Lấy đường dẫn tới một địa điểm
  Future<Map<String, dynamic>> getDirections(Position start, Position end) async {
    final response = await http.get(
      Uri.parse(
          'https://api.mapbox.com/directions/v5/mapbox/driving/'
              '${start.lng},${start.lat};${end.lng},${end.lat}'
              '?alternatives=true'
              '&geometries=geojson'
              '&steps=true'
              '&access_token=$_accessToken'
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Không thể lấy chỉ đường từ Mapbox: ${response.body}');
    }
  }

  // Tìm kiếm các địa điểm gần đó
  Future<List<Map<String, dynamic>>> searchNearbyPlaces(
      Position position,
      String query,
      {double radius = 10000}
      ) async {
    final response = await http.get(
      Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json'
              '?proximity=${position.lng},${position.lat}'
              '&limit=5'
              '&access_token=$_accessToken'
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'] as List;

      return features.map((feature) {
        return {
          'id': feature['id'],
          'name': feature['text'],
          'address': feature['place_name'],
          'longitude': feature['center'][0],
          'latitude': feature['center'][1],
        };
      }).toList();
    } else {
      throw Exception('Không thể tìm kiếm địa điểm: ${response.body}');
    }
  }

  // Tính khoảng cách giữa hai điểm
  double calculateDistance(Position pos1, Position pos2) {
    // Công thức Haversine để tính khoảng cách
    const double earthRadius = 6371000; // bán kính Trái Đất tính bằng mét

    double toRadians(double degree) {
      return degree * math.pi / 180;
    }

    final double lat1 = toRadians(pos1.lat.toDouble());
    final double lon1 = toRadians(pos1.lng.toDouble());
    final double lat2 = toRadians(pos2.lat.toDouble());
    final double lon2 = toRadians(pos2.lng.toDouble());

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance / 1000; // Chuyển đổi từ mét sang km
  }
}