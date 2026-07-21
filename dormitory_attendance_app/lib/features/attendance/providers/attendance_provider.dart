import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/attendance_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/device_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/config/app_config.dart';

class AttendanceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  
  List<AttendanceModel> _attendanceList = [];
  AttendanceModel? _todayAttendance;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _attendanceStats;

  // Getters
  List<AttendanceModel> get attendanceList => _attendanceList;
  AttendanceModel? get todayAttendance => _todayAttendance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get attendanceStats => _attendanceStats;
  bool get hasMarkedToday => _todayAttendance != null;

  // Mark attendance
  Future<bool> markAttendance({
    required UserModel user,
    required double targetLatitude,
    required double targetLongitude,
    double radius = 100.0,
    String? imageUrl,
    bool requireBiometric = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Check if already marked today
      if (await _hasMarkedToday(user.id)) {
        _setError('Attendance already marked for today');
        return false;
      }

      // Verify device
      final deviceId = await DeviceService.getDeviceId();
      if (user.deviceId != deviceId) {
        _setError('Device not registered. Please use your registered device.');
        return false;
      }

      // Verify location
      final currentPosition = await LocationService.getCurrentPosition();
      if (currentPosition == null) {
        _setError('Unable to get current location. Please enable location services.');
        return false;
      }

      final isWithinArea = await LocationService.isWithinAllowedArea(
        targetLatitude: targetLatitude,
        targetLongitude: targetLongitude,
        radius: radius,
      );

      if (!isWithinArea) {
        _setError('You are not within the allowed area to mark attendance.');
        return false;
      }

      // Get address
      final address = await LocationService.getAddressFromCoordinates(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
      );

      // Determine status (present or late)
      final now = DateTime.now();
      final cutoffTime = DateTime(now.year, now.month, now.day, 
          AppConfig.attendanceTimeoutHours, 0);
      final status = now.isAfter(cutoffTime) 
          ? AppConfig.statusLate 
          : AppConfig.statusPresent;

      // Create attendance record
      final attendance = AttendanceModel(
        id: _uuid.v4(),
        userId: user.id,
        userName: user.fullName,
        userEmail: user.email,
        roomId: user.roomId,
        date: DateTime.now(),
        checkInTime: DateTime.now(),
        status: status,
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        address: address,
        deviceId: deviceId,
        deviceFingerprint: await DeviceService.getDeviceFingerprint(),
        imageUrl: imageUrl,
        isManualEntry: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection(AppConfig.attendanceCollection)
          .doc(attendance.id)
          .set(attendance.toJson());

      _todayAttendance = attendance;
      
      // Send confirmation notification
      await NotificationService.showAttendanceConfirmation();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to mark attendance: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if attendance marked today
  Future<bool> _hasMarkedToday(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(AppConfig.attendanceCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking today attendance: $e');
      return false;
    }
  }

  // Load today's attendance
  Future<void> loadTodayAttendance(String userId) async {
    try {
      _setLoading(true);
      
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(AppConfig.attendanceCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _todayAttendance = AttendanceModel.fromJson({
          'id': snapshot.docs.first.id,
          ...snapshot.docs.first.data(),
        });
      } else {
        _todayAttendance = null;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load today\'s attendance: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load attendance history
  Future<void> loadAttendanceHistory(String userId, {int limit = 30}) async {
    try {
      _setLoading(true);
      
      final snapshot = await _firestore
          .collection(AppConfig.attendanceCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      _attendanceList = snapshot.docs
          .map((doc) => AttendanceModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load attendance history: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get attendance statistics
  Future<void> loadAttendanceStats(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      final snapshot = await _firestore
          .collection(AppConfig.attendanceCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      final attendances = snapshot.docs
          .map((doc) => AttendanceModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      final totalDays = attendances.length;
      final presentDays = attendances.where((a) => a.isPresent).length;
      final lateDays = attendances.where((a) => a.isLate).length;
      final absentDays = attendances.where((a) => a.isAbsent).length;
      final attendanceRate = totalDays > 0 
          ? ((presentDays + lateDays) / totalDays * 100).toStringAsFixed(1)
          : '0.0';

      _attendanceStats = {
        'totalDays': totalDays,
        'presentDays': presentDays,
        'lateDays': lateDays,
        'absentDays': absentDays,
        'attendanceRate': attendanceRate,
      };
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load attendance stats: $e');
    }
  }

  // Manual attendance entry (for managers/admins)
  Future<bool> manualAttendanceEntry({
    required String userId,
    required String userName,
    required String userEmail,
    required String status,
    required String approvedBy,
    String? roomId,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final attendance = AttendanceModel(
        id: _uuid.v4(),
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        roomId: roomId,
        date: DateTime.now(),
        checkInTime: DateTime.now(),
        status: status,
        notes: notes,
        isManualEntry: true,
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConfig.attendanceCollection)
          .doc(attendance.id)
          .set(attendance.toJson());

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create manual attendance entry: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearAttendanceList() {
    _attendanceList = [];
    _todayAttendance = null;
    _attendanceStats = null;
    notifyListeners();
  }
}
