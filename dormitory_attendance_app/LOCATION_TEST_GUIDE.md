# Location Testing Guide

## Overview
This guide helps you test the location-based attendance marking feature of the Dormitory Attendance App.

## Prerequisites

### 1. Physical Device Required
- Location features MUST be tested on a physical device (Android or iOS)
- Emulators have limited GPS simulation capabilities
- Biometric authentication also requires a physical device

### 2. Permissions Setup
The app requires the following permissions:
- **Location** (Fine & Coarse) - For GPS tracking
- **Camera** - For attendance photos (optional)
- **Biometric** - For fingerprint/face authentication
- **Notifications** - For attendance reminders

## Location Service Features

### 1. GPS Geofencing
The app verifies that students are physically at the dormitory when marking attendance.

**How it works:**
- Admin sets dormitory coordinates (latitude, longitude)
- Admin sets geofence radius (default: 100 meters)
- When student marks attendance, app checks if they're within the radius
- If outside the radius, attendance is rejected

### 2. Location Accuracy
- Uses high accuracy GPS (LocationAccuracy.high)
- 10-second timeout for location acquisition
- Validates location accuracy (should be ≤20 meters)

### 3. Anti-Spoofing
- Device movement detection (checks if device is stationary)
- Device fingerprinting
- Device binding (one device per student)

## Testing Steps

### Step 1: Configure System Settings (Admin)
1. Login as admin
2. Go to System Settings
3. Set dormitory location:
   - **Latitude**: Your dormitory's latitude (e.g., 40.7128)
   - **Longitude**: Your dormitory's longitude (e.g., -74.0060)
   - **Geofence Radius**: 100 meters (adjust as needed)
4. Enable/disable biometric requirement
5. Save settings

### Step 2: Test Location Permission Flow
1. Login as student
2. Navigate to "Mark Attendance"
3. App should request location permission
4. Grant permission
5. Verify "Location Services" shows green checkmark

### Step 3: Test Within Geofence (Success Case)
1. Be physically at the dormitory (within the radius)
2. Click "Mark Attendance"
3. Expected behavior:
   - Status shows "Verifying location..."
   - If biometric enabled, shows "Authenticating..."
   - Status shows "Marking attendance..."
   - Success message: "Attendance marked successfully!"
   - Redirects to dashboard
   - Today's attendance shows as "Present" or "Late"

### Step 4: Test Outside Geofence (Failure Case)
1. Be physically away from the dormitory (outside the radius)
2. Click "Mark Attendance"
3. Expected behavior:
   - Status shows "Verifying location..."
   - Error message: "You are not within the allowed area to mark attendance."
   - Attendance is NOT marked

### Step 5: Test Location Services Disabled
1. Disable location services on your device
2. Open the app and go to "Mark Attendance"
3. Expected behavior:
   - Status shows "Location services are disabled"
   - "Mark Attendance" button is disabled
   - "Grant Permission" button appears
   - Click "Grant Permission" to open settings

### Step 6: Test Already Marked Today
1. Mark attendance successfully
2. Try to mark attendance again on the same day
3. Expected behavior:
   - Error message: "Attendance already marked for today"
   - Attendance is NOT duplicated

## Location Service Methods

### Key Methods in LocationService:

```dart
// Check if location is enabled
await LocationService.isLocationEnabled()

// Request location permission
await LocationService.requestLocationPermission()

// Get current GPS position
Position? position = await LocationService.getCurrentPosition()

// Check if within allowed area
bool isWithin = await LocationService.isWithinAllowedArea(
  targetLatitude: 40.7128,
  targetLongitude: -74.0060,
  radius: 100.0,
)

// Get address from coordinates
String? address = await LocationService.getAddressFromCoordinates(
  latitude: 40.7128,
  longitude: -74.0060,
)

// Calculate distance between two points
double distance = LocationService.calculateDistance(
  lat1: 40.7128, lon1: -74.0060,
  lat2: 40.7580, lon2: -73.9855,
)
```

## Troubleshooting

### Issue: "Unable to get current location"
**Solutions:**
- Ensure location services are enabled on device
- Grant location permission to the app
- Check if GPS signal is available (go outdoors if indoors)
- Wait a few seconds for GPS to acquire signal

### Issue: "You are not within the allowed area"
**Solutions:**
- Verify you're physically at the dormitory
- Check admin has set correct dormitory coordinates
- Check geofence radius is appropriate (not too small)
- Use a GPS testing app to verify your actual coordinates

### Issue: Location permission denied
**Solutions:**
- Go to device Settings → Apps → Dormitory Attendance
- Enable Location permission
- Restart the app

### Issue: Low location accuracy
**Solutions:**
- Go outdoors for better GPS signal
- Ensure device has clear view of sky
- Wait for GPS to stabilize (may take 30-60 seconds)
- Check device location settings are set to "High Accuracy"

## Testing Checklist

- [ ] Location permission request works
- [ ] Location services check works
- [ ] GPS coordinates are acquired successfully
- [ ] Geofencing validation works (inside radius)
- [ ] Geofencing validation works (outside radius)
- [ ] Address is retrieved from coordinates
- [ ] Biometric authentication works (if enabled)
- [ ] Attendance is saved to Firestore
- [ ] Duplicate attendance prevention works
- [ ] Error messages are clear and helpful
- [ ] Location accuracy is validated
- [ ] Device verification works

## Production Deployment Notes

1. **Set Real Coordinates**: Replace test coordinates with actual dormitory location
2. **Adjust Radius**: Fine-tune geofence radius based on dormitory size
3. **Test on Site**: Always test at the actual dormitory location
4. **Monitor Accuracy**: Track location accuracy in production
5. **Handle Edge Cases**: Students at dormitory boundaries may have issues

## Getting Dormitory Coordinates

### Method 1: Google Maps
1. Open Google Maps
2. Search for your dormitory
3. Right-click on the location
4. Click on the coordinates to copy them
5. Format: Latitude, Longitude (e.g., 40.7128, -74.0060)

### Method 2: GPS App
1. Install a GPS app on your phone
2. Stand at the center of the dormitory
3. Note the latitude and longitude
4. Use these coordinates in admin settings

### Method 3: Use the App
1. Go to the dormitory
2. Use LocationService.getCurrentPosition() in debug mode
3. Log the coordinates
4. Use these coordinates in admin settings

## Important Notes

- Location accuracy varies by device and environment
- Indoor GPS may be less accurate than outdoor
- Tall buildings can interfere with GPS signals
- Weather conditions can affect GPS accuracy
- Always test with multiple devices and locations
- Consider a reasonable geofence radius (100-200 meters recommended)
