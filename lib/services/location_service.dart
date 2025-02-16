import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;

  LocationService._internal();

  static const platform =
      MethodChannel('com.example.flutter_geo_location/location');

  LocationController get _locationController => Get.find<LocationController>();

  Future<void> startLocationUpdates() async {
    try {
      platform.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'locationUpdate':
            final Map<String, dynamic> arguments =
                Map<String, dynamic>.from(call.arguments);
            _locationController.updateLocation(
              arguments['latitude'] as double,
              arguments['longitude'] as double,
            );
            break;
          case 'locationServicesDisabled':
            Get.snackbar(
              'Location Services Disabled',
              'Please enable location services to use this app',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 5),
              onTap: (_) {
                platform.invokeMethod('promptEnableLocation');
              },
            );
            break;
        }
      });

      await platform.invokeMethod('startLocationUpdates');
    } on PlatformException catch (e) {
      print("Failed to start location updates: '${e.message}'.");
    }
  }

  Future<void> stopLocationUpdates() async {
    try {
      await platform.invokeMethod('stopLocationUpdates');
    } on PlatformException catch (e) {
      print("Failed to stop location updates: '${e.message}'.");
    }
  }
}
