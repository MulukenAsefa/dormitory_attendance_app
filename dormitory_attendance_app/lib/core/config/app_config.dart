class AppConfig {
  // App Information
  static const String appName = 'Dormitory Attendance';
  static const String appVersion = '1.0.0';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'dormitory-attendance-app';
  
  // Geofencing Configuration
  static const double defaultGeofenceRadius = 100.0; // meters
  static const double maxGeofenceRadius = 500.0; // meters
  
  // Attendance Configuration
  static const int attendanceTimeoutHours = 22; // 10 PM
  static const int lateAttendanceGraceMinutes = 30;
  
  // Device Configuration
  static const int maxDevicesPerStudent = 1;
  
  // Notification Configuration
  static const String notificationChannelId = 'dormitory_attendance';
  static const String notificationChannelName = 'Dormitory Attendance';
  
  // Security Configuration
  static const int passwordMinLength = 8;
  static const int otpExpiryMinutes = 10;
  
  // File Upload Configuration
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];
  
  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  
  // Cache Configuration
  static const int cacheExpiryHours = 24;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  // User Roles
  static const String roleStudent = 'student';
  static const String roleManager = 'manager';
  static const String roleAdmin = 'admin';
  
  // Attendance Status
  static const String statusPresent = 'present';
  static const String statusAbsent = 'absent';
  static const String statusLate = 'late';
  static const String statusExcused = 'excused';
  
  // Collections
  static const String usersCollection = 'users';
  static const String attendanceCollection = 'attendance';
  static const String roomsCollection = 'rooms';
  static const String devicesCollection = 'devices';
  static const String settingsCollection = 'settings';
  static const String notificationsCollection = 'notifications';
}