import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

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
  Future<Map<String, dynamic>> getRoute(LatLng origin, LatLng destination) async {
    final response = await http.get(Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
            '${origin.longitude},${origin.latitude};'
            '${destination.longitude},${destination.latitude}'
            '?alternatives=true'
            '&geometries=geojson'
            '&steps=true'
            '&access_token=$_accessToken'
    ));

    return json.decode(response.body);
  }
}