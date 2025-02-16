import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_app_name/utils/constants.dart';
import '../controllers/location_controller.dart';
import '../controllers/auth_controller.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationController _locationController = Get.find();
  final AuthController _authController = Get.find();
  final LocationService _locationService = LocationService();

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationService.startLocationUpdates();
  }

  @override
  void dispose() {
    _locationService.stopLocationUpdates();
    super.dispose();
  }

  void _showCoordinatesDialog(BuildContext context) {
    _latController.text = Constants.centerLatitude.toString();
    _longController.text = Constants.centerLongitude.toString();

    Get.dialog(
      AlertDialog(
        title: const Text('Set Geofence Center'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _longController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final lat = double.tryParse(_latController.text);
              final long = double.tryParse(_longController.text);
              if (lat != null && long != null) {
                _locationController.updateGeofenceCenter(lat, long);
                Get.back();
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter valid coordinates',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;

    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final confirm = await Get.dialog<bool>(
                      AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Get.back(result: true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (confirm) {
                  await _locationService.stopLocationUpdates();
                  await _authController.logout();
                  Get.offAllNamed('/login');
                }
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Current Location:',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lat: ${_locationController.currentLatitude.value.toStringAsFixed(6)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Long: ${_locationController.currentLongitude.value.toStringAsFixed(6)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last Update: ${_locationController.lastUpdateTime.value}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              Obx(() {
                final isInGeofence = _locationController.isInGeofence.value;
                return ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInGeofence ? Colors.green : Colors.red,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(40),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCoordinatesDialog(context),
          child: const Icon(Icons.location_on),
        ),
      ),
    );
  }
}
