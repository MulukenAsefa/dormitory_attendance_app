# 📱 Run App on Your Phone - Quick Guide

## ✅ PRE-FLIGHT CHECKLIST

Before running, verify these are complete:

### Firebase Setup
- [x] Firebase project created ✅
- [x] `google-services.json` downloaded and placed in `android/app/` ✅
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore database created
- [ ] Firestore security rules published
- [ ] Firebase Storage enabled

### Phone Setup
- [ ] USB debugging enabled on phone
- [ ] Phone connected via USB cable
- [ ] Phone appears in `flutter devices` command

---

## 🚀 STEP-BY-STEP: RUN ON YOUR PHONE

### Step 1: Enable USB Debugging on Phone

#### For Android:
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times (enables Developer Options)
3. Go back to **Settings** → **Developer Options**
4. Enable **USB Debugging**
5. Connect phone to computer via USB
6. On phone, tap **Allow** when prompted "Allow USB debugging?"

### Step 2: Verify Phone Connection

Open terminal/command prompt and run:
```bash
flutter devices
```

You should see something like:
```
Found 2 devices:
  SM G960F (mobile) • 988d1a31 • android-arm64 • Android 10 (API 29)
  Chrome (web)      • chrome   • web-javascript • Google Chrome 120.0
```

If you see your phone listed, you're good to go! ✅

### Step 3: Install Dependencies

In the project folder, run:
```bash
cd dormitory_attendance_app
flutter pub get
```

Wait for it to complete (should take 30-60 seconds).

### Step 4: Run the App

Run this command:
```bash
flutter run
```

**OR** if you have multiple devices:
```bash
flutter run -d <device-id>
```

Example:
```bash
flutter run -d 988d1a31
```

### Step 5: Wait for Build

First build takes 3-5 minutes. You'll see:
```
Running Gradle task 'assembleDebug'...
Building APK...
Installing APK...
Launching app...
```

When you see:
```
Flutter run key commands.
r Hot reload.
R Hot restart.
```

The app is running! 🎉

---

## 📱 FIRST TIME SETUP IN APP

### 1. Create Admin User

Since this is first run, you need an admin:

**Option A: Register in App (Recommended)**
1. Open app → Click "Register"
2. Fill in details:
   - Email: admin@dormitory.com
   - Password: Admin@123
   - First Name: Admin
   - Last Name: User
   - Phone: +1234567890
3. Click "Register"

**Then manually change role to admin:**
1. Go to Firebase Console → Firestore Database
2. Find the user document you just created
3. Click on it → Edit
4. Change `role` field from `"student"` to `"admin"`
5. Save
6. Restart app and login again

**Option B: Create Admin Directly in Firestore**
1. Go to Firebase Console → Authentication
2. Click "Add user"
   - Email: admin@dormitory.com
   - Password: Admin@123
3. Copy the UID (e.g., `abc123xyz`)
4. Go to Firestore Database
5. Create collection: `users`
6. Create document with ID = the UID you copied
7. Add fields:
```
id: abc123xyz (same as UID)
email: admin@dormitory.com
firstName: Admin
lastName: User
role: admin
phoneNumber: +1234567890
isActive: true
isEmailVerified: true
isDeviceRegistered: false
createdAt: 2024-01-15T10:00:00.000Z
```

### 2. Login as Admin

1. Open app
2. Login with admin credentials
3. You'll see Admin Dashboard

### 3. Configure System Settings

1. Go to **System Settings** (in admin panel)
2. Set these values:
   - **Dorm Latitude**: Your location latitude (e.g., 40.7128)
   - **Dorm Longitude**: Your location longitude (e.g., -74.0060)
   - **Geofence Radius**: 100 (meters) - for testing, use 500
   - **Attendance Deadline**: 22 (10 PM)
   - **Late Grace Minutes**: 30
   - **Require Biometric**: false (for testing)
   - **Require Photo**: false (for testing)

**To get your current location:**
- Use Google Maps
- Right-click on your location
- Click the coordinates to copy them
- Example: 40.7128, -74.0060

### 4. Create Test Student

1. In Admin Dashboard → **User Management**
2. Click "Add User"
3. Fill in:
   - Email: student@test.com
   - Password: Student@123
   - First Name: Test
   - Last Name: Student
   - Role: student
   - Room: 101 (create room first if needed)
4. Save

### 5. Test Student Flow

1. Logout from admin
2. Login as student (student@test.com / Student@123)
3. Register device (first time only)
4. Go to Dashboard
5. Click "Mark Attendance"
6. Grant location permissions when prompted
7. Make sure you're within the geofence radius
8. Click "Mark Attendance"
9. Should see success message! ✅

---

## 🐛 TROUBLESHOOTING

### Problem: "No devices found"
**Solution:**
- Make sure USB debugging is enabled
- Try different USB cable
- Try different USB port
- Restart phone
- Run `adb devices` to check connection

### Problem: "Build failed"
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Problem: "Firebase not initialized"
**Solution:**
- Check `google-services.json` is in `android/app/` folder
- Make sure you ran `flutter pub get`
- Try `flutter clean` then `flutter run`

### Problem: "Location permission denied"
**Solution:**
- Go to phone Settings → Apps → Dormitory Attendance → Permissions
- Enable Location (set to "Allow all the time" or "Allow only while using")

### Problem: "Not within allowed area"
**Solution:**
- Check system settings for correct GPS coordinates
- Increase geofence radius temporarily (e.g., 500 meters)
- Make sure location services are enabled on phone
- Make sure you're physically near the set location

### Problem: "Device not registered"
**Solution:**
- Complete device registration flow first
- Check Firestore for device document
- Admin can reset device registration if needed

### Problem: App crashes on startup
**Solution:**
- Check Firebase services are enabled:
  - Authentication (Email/Password)
  - Firestore Database
  - Storage
- Check Firestore security rules are published
- Check logs: `flutter run --verbose`

---

## 📊 TESTING CHECKLIST

After app is running, test these features:

### Student Features
- [ ] Register new student account
- [ ] Login with student credentials
- [ ] Register device
- [ ] View dashboard
- [ ] Mark attendance (must be within geofence)
- [ ] View attendance history
- [ ] View monthly statistics
- [ ] Receive notifications

### Manager Features
- [ ] Login as manager
- [ ] View dashboard with statistics
- [ ] See present/absent/late students
- [ ] Approve late attendance
- [ ] Manual attendance override
- [ ] Generate reports

### Admin Features
- [ ] Login as admin
- [ ] View dashboard
- [ ] Add new users (students/managers)
- [ ] Create rooms
- [ ] Configure system settings
- [ ] Reset device registration
- [ ] View analytics

---

## 🎯 QUICK COMMANDS REFERENCE

```bash
# Check connected devices
flutter devices

# Install dependencies
flutter pub get

# Run app
flutter run

# Run on specific device
flutter run -d <device-id>

# Clean build
flutter clean

# Check for issues
flutter doctor

# View logs
flutter logs

# Hot reload (while app is running)
Press 'r' in terminal

# Hot restart (while app is running)
Press 'R' in terminal

# Quit app
Press 'q' in terminal
```

---

## ✅ SUCCESS INDICATORS

You'll know it's working when:

1. ✅ App installs on phone without errors
2. ✅ Splash screen appears
3. ✅ Login/Register screens load
4. ✅ Can register new account
5. ✅ Can login successfully
6. ✅ Dashboard loads with data
7. ✅ Can mark attendance (if within geofence)
8. ✅ Can view attendance history
9. ✅ Notifications work

---

## 📞 STILL HAVING ISSUES?

Check these:
1. Firebase Console for errors
2. Flutter console for error messages
3. Phone logs (logcat for Android)
4. Firestore security rules are correct
5. All Firebase services are enabled
6. Phone has internet connection
7. Location services are enabled
8. All permissions are granted

---

## 🎉 YOU'RE READY!

If you've completed the checklist and followed the steps, your app should be running on your phone!

**Next Steps:**
1. Test all features
2. Create more test users
3. Test attendance marking
4. Test manager approval flow
5. Test admin functions
6. Generate reports

**Enjoy your Dormitory Attendance App!** 🚀
