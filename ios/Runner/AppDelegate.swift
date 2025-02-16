import UIKit
import Flutter
import CoreLocation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var locationHandler: LocationHandler?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.example.flutter_geo_location/location",
      binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "startLocationUpdates":
        self?.locationHandler = LocationHandler(channel: channel)
        self?.locationHandler?.startLocationUpdates()
        result(nil)
      case "stopLocationUpdates":
        self?.locationHandler?.stopLocationUpdates()
        result(nil)
      case "checkLocationServices":
        result(self?.locationHandler?.checkLocationServices() ?? false)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
