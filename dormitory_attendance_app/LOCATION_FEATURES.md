# Location Features Documentation

## Overview
The Dormitory Attendance App uses GPS-based geofencing to verify that students are physically present at the dormitory when marking attendance.

## Core Location Features

### 1. GPS Geofencing ✅
**Purpose:** Ensure students are at the dormitory when marking attendance

**How it works:**
- Admin configures dormitory coordinates (latitude, longitude)
- Admin sets geofence radius (default: 100 meters)
- When student marks attendance, app calculates distance from dormitory
- If distance > radius, attendance is rejected

**Implementation:**
```dart
final isWithinArea = await LocationService.isWithinAllowedArea(
  targetLatitude: dormLatitude,
  targetLongitude: dormLongitude,
  radius: geofenceRadius,
);
```

### 2. High Accuracy GPS ✅
**Configuration:**
- Accuracy: `LocationAccuracy.high`
- Timeout: 10 seconds
- Validation: Accuracy must be ≤20 meters

**Implementation:**
```dart
const locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  timeLimit: Duration(seconds: 10),
);
```

### 3. Permission Management ✅
**Permissions Required:**
- Android: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- iOS: `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysUsageDescription`

**Runtime Flow:**
1. Check if location services enabled
2. Check if permission granted
3. Request permission if needed
4. Handle permission denial gracefully

### 4. Address Lookup ✅
**Purpose:** Convert GPS coordinates to human-readable address

**Implementation:**
```dart
final address = await LocationService.getAddressFromCoordinates(
  latitude: position.latitude,
  longitude: position.longitude,
);
```

**Stored in Firestore:** Each attendance record includes the address for verification

### 5. Anti-Spoofing Measures ✅

#### Device Movement Detection
Checks if device is stationary (not being spoofed):
```dart
final isMoving = await LocationService.isDeviceMoving();
```
- Takes 3 position readings with 2-second intervals
- Calculates distance between readings
- If movement > 5 meters, flags as potentially spoofed

#### Device Binding
- Each student can only use ONE registered device
- Device ID is verified before marking attendance
- Prevents sharing devices or using multiple devices

#### Device Fingerprinting
- Unique device fingerprint generated
- Stored with each attendance record
- Helps detect device tampering

### 6. Location Accuracy Validation ✅
```dart
bool isAccurate = LocationService.isLocationAccurate(
  position,
  maxAccuracy: 20.0, // meters
);
```

### 7. Distance Calculation ✅
Uses Haversine formula to calculate distance between two GPS points:
```dart
double distance = LocationService.calculateDistance(
  lat1: currentLat,
  lon1: currentLon,
  lat2: targetLat,
  lon2: targetLon,
);
```

### 8. Real-time Position Streaming ✅
For advanced features (future use):
```dart
Stream<Position> positionStream = LocationService.getPositionStream();
```
- Updates every 10 meters
- High accuracy mode
- Can be used for live tracking

## Location Service API

### Main Methods

#### `isLocationEnabled()`
Checks if location services are enabled and permissions granted
```dart
bool enabled = await LocationService.isLocationEnabled();
```

#### `requestLocationPermission()`
Requests location permission from user
```dart
bool granted = await LocationService.requestLocationPermission();
```

#### `getCurrentPosition()`
Gets current GPS coordinates
```dart
Position? position = await LocationService.getCurrentPosition();
// Returns: latitude, longitude, accuracy, timestamp, etc.
```

#### `isWithinAllowedArea()`
Checks if current location is within geofence
```dart
bool isWithin = await LocationService.isWithinAllowedArea(
  targetLatitude: 40.7128,
  targetLongitude: -74.0060,
  radius: 100.0,
);
```

#### `calculateDistance()`
Calculates distance between two points in meters
```dart
double distance = LocationService.calculateDistance(
  lat1: 40.7128, lon1: -74.0060,
  lat2: 40.7580, lon2: -73.9855,
);
```

#### `getAddressFromCoordinates()`
Reverse geocoding - converts coordinates to address
```dart
String? address = await LocationService.getAddressFromCoordinates(
  latitude: 40.7128,
  longitude: -74.0060,
);
```

#### `getCoordinatesFromAddress()`
Forward geocoding - converts address to coordinates
```dart
Position? position = await LocationService.getCoordinatesFromAddress(
  'Times Square, New York, NY'
);
```

## Attendance Flow with Location

### Student Marks Attendance:

1. **Permission Check**
   - Check if location permission granted
   - Request if not granted
   - Show error if denied

2. **Location Services Check**
   - Verify GPS is enabled on device
   - Show error if disabled

3. **Get Current Position**
   - Acquire GPS coordinates (10s timeout)
   - Validate accuracy (≤20m)
   - Show error if unable to get position

4. **Geofence Validation**
   - Calculate distance from dormitory
   - Check if within allowed radius
   - Reject if outside geofence

5. **Device Verification**
   - Verify device ID matches registered device
   - Check device fingerprint
   - Reject if device mismatch

6. **Biometric Authentication** (if enabled)
   - Request fingerprint/face authentication
   - Reject if authentication fails

7. **Save Attendance**
   - Create attendance record with:
     - GPS coordinates
     - Address
     - Device info
     - Timestamp
     - Status (present/late)
   - Save to Firestore

8. **Confirmation**
   - Show success message
   - Send push notification
   - Update dashboard

## Security Considerations

### GPS Spoofing Prevention
1. **Device Movement Detection** - Detects if location is being faked
2. **Device Binding** - One device per student
3. **Device Fingerprinting** - Unique device identification
4. **Accuracy Validation** - Rejects low-accuracy readings
5. **Timestamp Verification** - Checks if location is current

### Privacy
- Location data is only collected when marking attendance
- No background location tracking
- Location data stored securely in Firestore
- Only accessible by authorized users (managers/admins)

## Configuration

### Admin Settings (Firestore: `settings/system`)
```json
{
  "dormLatitude": 40.7128,
  "dormLongitude": -74.0060,
  "geofenceRadius": 100.0,
  "requireBiometric": true,
  "attendanceTimeoutHours": 22
}
```

### Recommended Radius by Dormitory Size
- **Small** (1 building): 50-100 meters
- **Medium** (2-3 buildings): 100-200 meters
- **Large** (campus): 200-500 meters

## Troubleshooting

### Low GPS Accuracy
**Causes:**
- Indoor location (GPS works better outdoors)
- Tall buildings blocking signal
- Bad weather conditions
- Device GPS hardware issues

**Solutions:**
- Go outdoors or near windows
- Wait 30-60 seconds for GPS to stabilize
- Enable "High Accuracy" mode in device settings
- Restart device if GPS not working

### Geofence Too Strict
**Symptoms:**
- Students at dormitory can't mark attendance
- Frequent "not within allowed area" errors

**Solutions:**
- Increase geofence radius
- Verify dormitory coordinates are correct
- Test at different locations within dormitory

### Permission Issues
**Android:**
- Settings → Apps → Dormitory Attendance → Permissions → Location → Allow

**iOS:**
- Settings → Privacy → Location Services → Dormitory Attendance → While Using

## Testing Tips

1. **Get Dormitory Coordinates:**
   - Use Google Maps (right-click → coordinates)
   - Use GPS app at dormitory center
   - Use online coordinate finder

2. **Test Distance Calculation:**
   - Use online distance calculator
   - Verify geofence radius is appropriate
   - Test at dormitory boundaries

3. **Verify GPS Accuracy:**
   - Check position.accuracy value
   - Should be ≤20 meters for reliable results
   - Test at different times and locations

4. **Monitor in Production:**
   - Track failed attendance attempts
   - Analyze location accuracy patterns
   - Adjust geofence radius if needed

## Performance

- **GPS Acquisition:** 2-10 seconds (depends on signal)
- **Distance Calculation:** <1ms (instant)
- **Address Lookup:** 1-3 seconds (network dependent)
- **Total Time:** 3-15 seconds for complete flow

## Future Enhancements

- [ ] Offline location caching
- [ ] Multiple geofence zones (different buildings)
- [ ] Location history tracking
- [ ] Heat map of attendance locations
- [ ] Automatic radius adjustment based on GPS accuracy
- [ ] WiFi-based location verification (backup)
- [ ] Bluetooth beacon support (indoor positioning)

## Dependencies

- `geolocator: ^13.0.1` - GPS positioning
- `geocoding: ^3.0.0` - Address lookup
- `permission_handler: ^11.3.1` - Permission management

## Files

- **Service:** `lib/core/services/location_service.dart`
- **Provider:** `lib/features/attendance/providers/attendance_provider.dart`
- **Screen:** `lib/features/student/screens/mark_attendance_screen.dart`
- **Config:** `lib/core/config/app_config.dart`
- **Android Manifest:** `android/app/src/main/AndroidManifest.xml`
- **iOS Info.plist:** `ios/Runner/Info.plist`
