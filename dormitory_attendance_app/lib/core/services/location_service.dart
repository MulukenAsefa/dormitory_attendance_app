import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static const double _defaultRadius = 100.0; // meters

  /// Check if location services are enabled and permissions are granted
  static Future<bool> isLocationEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Request location permissions
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      if (!await isLocationEnabled()) {
        return null;
      }

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Check if current location is within the allowed area
  static Future<bool> isWithinAllowedArea({
    required double targetLatitude,
    required double targetLongitude,
    double radius = _defaultRadius,
  }) async {
    try {
      final currentPosition = await getCurrentPosition();
      if (currentPosition == null) {
        return false;
      }

      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        targetLatitude,
        targetLongitude,
      );

      return distance <= radius;
    } catch (e) {
      print('Error checking location: $e');
      return false;
    }
  }

  /// Calculate distance between two points
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Get address from coordinates
  static Future<String?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return null;
  }

  /// Get coordinates from address
  static Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (e) {
      print('Error getting coordinates: $e');
    }
    return null;
  }

  /// Start location tracking
  static Stream<Position> getPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Check if device is moving (for anti-spoofing)
  static Future<bool> isDeviceMoving() async {
    try {
      final positions = <Position>[];
      
      // Get 3 position readings with 2-second intervals
      for (int i = 0; i < 3; i++) {
        final position = await getCurrentPosition();
        if (position != null) {
          positions.add(position);
        }
        if (i < 2) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (positions.length < 2) {
        return false;
      }

      // Check if there's significant movement
      for (int i = 1; i < positions.length; i++) {
        final distance = calculateDistance(
          lat1: positions[i - 1].latitude,
          lon1: positions[i - 1].longitude,
          lat2: positions[i].latitude,
          lon2: positions[i].longitude,
        );
        
        // If movement is more than 5 meters, consider it as moving
        if (distance > 5) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error checking device movement: $e');
      return false;
    }
  }

  /// Validate location accuracy
  static bool isLocationAccurate(Position position, {double maxAccuracy = 20.0}) {
    return position.accuracy <= maxAccuracy;
  }

  /// Get location settings for the app
  static LocationSettings getLocationSettings({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 0,
    Duration? timeLimit,
  }) {
    return LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      timeLimit: timeLimit,
    );
  }
}