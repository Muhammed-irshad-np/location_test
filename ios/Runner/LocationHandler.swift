import Foundation
import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone  // Remove distance filter
    }
    
    func startLocationUpdates() {
        if !CLLocationManager.locationServicesEnabled() {
            channel.invokeMethod("locationServicesDisabled", nil)
            // This will automatically prompt the user to enable location services
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()  // Single immediate update
        locationManager.startUpdatingLocation()  // Continuous updates
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
        
        // Add logging
        print("Location Update - Lat: \(location.coordinate.latitude), Long: \(location.coordinate.longitude)")
        channel.invokeMethod("locationUpdate", arguments: locationData)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }
    
    func checkLocationServices() -> Bool {
        let isEnabled = CLLocationManager.locationServicesEnabled()
        if !isEnabled {
            locationManager.requestWhenInUseAuthorization()
        }
        return isEnabled
    }
} 