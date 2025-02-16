package com.example.flutter_geo_location

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodChannel

class LocationHandler(private val activity: Activity, private val channel: MethodChannel) {
    private var locationManager: LocationManager? = null
    private var locationListener: LocationListener? = null
    
    companion object {
        private const val PERMISSION_REQUEST_CODE = 123
    }

    fun startLocationUpdates() {
        if (!isLocationEnabled()) {
            promptEnableLocation()
            return
        }
        
        if (checkPermissions()) {
            initializeLocationUpdates()
        } else {
            requestPermissions()
        }
    }

    fun stopLocationUpdates() {
        locationListener?.let { listener ->
            locationManager?.removeUpdates(listener)
        }
    }

    private fun isLocationEnabled(): Boolean {
        locationManager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        return locationManager?.isProviderEnabled(LocationManager.GPS_PROVIDER) ?: false
    }

    fun promptEnableLocation() {
        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
        activity.startActivity(intent)
        
        // Notify Flutter that location services are disabled
        activity.runOnUiThread {
            channel.invokeMethod("locationServicesDisabled", null)
        }
    }

    private fun checkPermissions(): Boolean {
        return ContextCompat.checkSelfPermission(
            activity,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestPermissions() {
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ),
            PERMISSION_REQUEST_CODE
        )
    }

    private fun initializeLocationUpdates() {
        locationManager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        locationListener = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                val locationData = mapOf(
                    "latitude" to location.latitude,
                    "longitude" to location.longitude
                )
                // Add logging
                println("Location Update - Lat: ${location.latitude}, Long: ${location.longitude}")
                activity.runOnUiThread {
                    channel.invokeMethod("locationUpdate", locationData)
                }
            }

            override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
            override fun onProviderEnabled(provider: String) {}
            override fun onProviderDisabled(provider: String) {}
        }

        if (ActivityCompat.checkSelfPermission(
                activity,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            locationManager?.requestLocationUpdates(
                LocationManager.GPS_PROVIDER,
                2000,
                0f,
                locationListener!!
            )

            locationManager?.requestLocationUpdates(
                LocationManager.NETWORK_PROVIDER,
                2000,
                0f,
                locationListener!!
            )
        }

        // Get last known location immediately
        locationManager?.getLastKnownLocation(LocationManager.GPS_PROVIDER)?.let { location ->
            locationListener?.onLocationChanged(location)
        }
    }

    fun checkLocationServices(): Boolean {
        locationManager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val isEnabled = locationManager?.isProviderEnabled(LocationManager.GPS_PROVIDER) ?: false
        if (!isEnabled) {
            promptEnableLocation()
        }
        return isEnabled
    }
} 