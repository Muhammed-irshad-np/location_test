package com.example.flutter_geo_location

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private lateinit var locationHandler: LocationHandler
    private val CHANNEL = "com.example.flutter_geo_location/location"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize locationHandler first
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        locationHandler = LocationHandler(this, channel)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startLocationUpdates" -> {
                    locationHandler.startLocationUpdates()
                    result.success(null)
                }
                "stopLocationUpdates" -> {
                    locationHandler.stopLocationUpdates()
                    result.success(null)
                }
                "checkLocationServices" -> {
                    result.success(locationHandler.checkLocationServices())
                }
                "promptEnableLocation" -> {
                    locationHandler.promptEnableLocation()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
