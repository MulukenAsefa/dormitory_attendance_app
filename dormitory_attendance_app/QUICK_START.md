# Quick Start Guide

## 🚀 Run the App

### 1. Check Flutter Setup
```bash
flutter doctor
```

### 2. Get Dependencies
```bash
cd dormitory_attendance_app
flutter pub get
```

### 3. Connect Your Device
```bash
# List available devices
flutter devices

# You should see your Android or iOS device
```

### 4. Run the App
```bash
# Run on connected device
flutter run

# Or run in release mode for better performance
flutter run --release
```

## 📱 Test Location Features

### Important: Use Physical Device
- Emulators have limited GPS capabilities
- Location testing requires a real device
- Biometric features also need physical device

### Test Checklist:
1. ✅ Grant location permission when prompted
2. ✅ Enable location services on device
3. ✅ Go to "Mark Attendance" screen
4. ✅ Verify location status shows green
5. ✅ Test marking attendance (must be at dormitory)

## 🔧 Common Issues

### "Location permission denied"
→ Go to device Settings → Apps → Dormitory Attendance → Permissions → Enable Location

### "Location services disabled"
→ Enable GPS/Location in device settings

### "You are not within the allowed area"
→ You must be physically at the dormitory to mark attendance
→ Admin must configure correct dormitory coordinates

### "Firebase not configured"
→ See SETUP_GUIDE.md for Firebase setup instructions

## 📍 Location Service Status

✅ GPS permission handling
✅ Location services check
✅ Geofencing validation
✅ High accuracy positioning
✅ Address lookup
✅ Anti-spoofing measures

## 🔐 Required Permissions

- Location (Fine & Coarse)
- Camera (for photos)
- Biometric (fingerprint/face)
- Notifications

All permissions are requested at runtime when needed.
