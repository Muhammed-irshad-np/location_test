import 'package:get/get.dart';
import 'dart:math';
import '../utils/constants.dart';
import '../services/location_service.dart';

class LocationController extends GetxController {
  final isInGeofence = false.obs;
  final currentLatitude = 0.0.obs;
  final currentLongitude = 0.0.obs;
  final centerLatitude = Constants.centerLatitude.obs;
  final centerLongitude = Constants.centerLongitude.obs;
  final LocationService _locationService = LocationService();
  final lastUpdateTime = ''.obs;

  void updateLocation(double latitude, double longitude) {
    currentLatitude.value = latitude;
    currentLongitude.value = longitude;
    lastUpdateTime.value =
        DateTime.now().toIso8601String().split('T')[1].substring(0, 12);
    print(
        'Flutter Location Update - Lat: $latitude, Long: $longitude, Time: ${lastUpdateTime.value}');
    _checkGeofence();
  }

  void updateGeofenceCenter(double lat, double long) {
    centerLatitude.value = lat;
    centerLongitude.value = long;
    _checkGeofence();
    print('Geofence center updated - Lat: $lat, Long: $long');
  }

  void _checkGeofence() {
    double distance = _calculateDistance(
      currentLatitude.value,
      currentLongitude.value,
      centerLatitude.value,
      centerLongitude.value,
    );
    isInGeofence.value = distance <= Constants.geofenceRadius;
    print(
        'Geofence Status - Distance: ${distance.toStringAsFixed(2)}m, Inside: ${isInGeofence.value}');
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; 
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<bool> checkLocationServices() async {
    try {
      final bool isEnabled =
          await LocationService.platform.invokeMethod('checkLocationServices');
      if (!isEnabled) {
        Get.snackbar(
          'Location Services Disabled',
          'Please enable location services to use this app',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
      return isEnabled;
    } catch (e) {
      print("Failed to check location services: $e");
      return false;
    }
  }
}
