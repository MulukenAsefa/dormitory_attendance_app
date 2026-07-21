import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/user_model.dart';
import '../../../core/models/attendance_model.dart';
import '../../../core/config/app_config.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  
  List<UserModel> _students = [];
  List<UserModel> _managers = [];
  List<RoomModel> _rooms = [];
  Map<String, dynamic>? _systemSettings;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _dashboardStats;

  // Getters
  List<UserModel> get students => _students;
  List<UserModel> get managers => _managers;
  List<RoomModel> get rooms => _rooms;
  Map<String, dynamic>? get systemSettings => _systemSettings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;

  // Load all students
  Future<void> loadStudents() async {
    try {
      _setLoading(true);
      
      final snapshot = await _firestore
          .collection(AppConfig.usersCollection)
          .where('role', isEqualTo: AppConfig.roleStudent)
          .orderBy('firstName')
          .get();

      _students = snapshot.docs
          .map((doc) => UserModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load students: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all managers
  Future<void> loadManagers() async {
    try {
      _setLoading(true);
      
      final snapshot = await _firestore
          .collection(AppConfig.usersCollection)
          .where('role', isEqualTo: AppConfig.roleManager)
          .orderBy('firstName')
          .get();

      _managers = snapshot.docs
          .map((doc) => UserModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load managers: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add new user
  Future<bool> addUser({
    required String email,
    required String firstName,
    required String lastName,
    required String role,
    String? phoneNumber,
    String? roomId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Note: In production, you'd use Firebase Admin SDK or Cloud Functions
      // to create users with passwords
      
      final userId = _uuid.v4();
      final userData = UserModel(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phoneNumber: phoneNumber,
        roomId: roomId,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(userId)
          .set(userData.toJson());

      if (role == AppConfig.roleStudent) {
        _students.add(userData);
      } else if (role == AppConfig.roleManager) {
        _managers.add(userData);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user
  Future<bool> updateUser({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? roomId,
    bool? isActive,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final updates = <String, dynamic>{};
      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (roomId != null) updates['roomId'] = roomId;
      if (isActive != null) updates['isActive'] = isActive;

      if (updates.isNotEmpty) {
        updates['updatedAt'] = DateTime.now().toIso8601String();

        await _firestore
            .collection(AppConfig.usersCollection)
            .doc(userId)
            .update(updates);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(userId)
          .delete();

      _students.removeWhere((user) => user.id == userId);
      _managers.removeWhere((user) => user.id == userId);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset device registration
  Future<bool> resetDeviceRegistration(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(userId)
          .update({
        'deviceId': null,
        'isDeviceRegistered': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to reset device registration: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load rooms
  Future<void> loadRooms() async {
    try {
      _setLoading(true);
      
      final snapshot = await _firestore
          .collection(AppConfig.roomsCollection)
          .orderBy('roomNumber')
          .get();

      _rooms = snapshot.docs
          .map((doc) => RoomModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load rooms: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add room
  Future<bool> addRoom({
    required String roomNumber,
    required int capacity,
    String? building,
    String? floor,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final roomId = _uuid.v4();
      final room = RoomModel(
        id: roomId,
        roomNumber: roomNumber,
        capacity: capacity,
        building: building,
        floor: floor,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConfig.roomsCollection)
          .doc(roomId)
          .set(room.toJson());

      _rooms.add(room);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add room: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update room
  Future<bool> updateRoom({
    required String roomId,
    String? roomNumber,
    int? capacity,
    String? building,
    String? floor,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final updates = <String, dynamic>{};
      if (roomNumber != null) updates['roomNumber'] = roomNumber;
      if (capacity != null) updates['capacity'] = capacity;
      if (building != null) updates['building'] = building;
      if (floor != null) updates['floor'] = floor;

      if (updates.isNotEmpty) {
        updates['updatedAt'] = DateTime.now().toIso8601String();

        await _firestore
            .collection(AppConfig.roomsCollection)
            .doc(roomId)
            .update(updates);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update room: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete room
  Future<bool> deleteRoom(String roomId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestore
          .collection(AppConfig.roomsCollection)
          .doc(roomId)
          .delete();

      _rooms.removeWhere((room) => room.id == roomId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete room: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load system settings
  Future<void> loadSystemSettings() async {
    try {
      _setLoading(true);
      
      final doc = await _firestore
          .collection(AppConfig.settingsCollection)
          .doc('system')
          .get();

      if (doc.exists) {
        _systemSettings = doc.data();
      } else {
        // Create default settings
        _systemSettings = _getDefaultSettings();
        await _firestore
            .collection(AppConfig.settingsCollection)
            .doc('system')
            .set(_systemSettings!);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load system settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update system settings
  Future<bool> updateSystemSettings(Map<String, dynamic> settings) async {
    try {
      _setLoading(true);
      _clearError();

      settings['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore
          .collection(AppConfig.settingsCollection)
          .doc('system')
          .update(settings);

      _systemSettings = {...?_systemSettings, ...settings};
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update system settings: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Map<String, dynamic> _getDefaultSettings() {
    return {
      'dormLatitude': 0.0,
      'dormLongitude': 0.0,
      'geofenceRadius': AppConfig.defaultGeofenceRadius,
      'attendanceTimeoutHour': AppConfig.attendanceTimeoutHours,
      'lateGraceMinutes': AppConfig.lateAttendanceGraceMinutes,
      'requireBiometric': false,
      'requirePhoto': false,
      'curfewTime': '22:00',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Load dashboard statistics
  Future<void> loadDashboardStats() async {
    try {
      _setLoading(true);
      
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get today's attendance
      final attendanceSnapshot = await _firestore
          .collection(AppConfig.attendanceCollection)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      final attendances = attendanceSnapshot.docs
          .map((doc) => AttendanceModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      // Get total students
      final studentsSnapshot = await _firestore
          .collection(AppConfig.usersCollection)
          .where('role', isEqualTo: AppConfig.roleStudent)
          .where('isActive', isEqualTo: true)
          .get();

      final totalStudents = studentsSnapshot.docs.length;
      final presentCount = attendances.where((a) => a.isPresent).length;
      final lateCount = attendances.where((a) => a.isLate).length;
      final absentCount = totalStudents - attendances.length;

      _dashboardStats = {
        'totalStudents': totalStudents,
        'presentCount': presentCount,
        'lateCount': lateCount,
        'absentCount': absentCount,
        'attendanceRate': totalStudents > 0 
            ? ((presentCount + lateCount) / totalStudents * 100).toStringAsFixed(1)
            : '0.0',
      };
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load dashboard stats: $e');
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
}

// Room Model
class RoomModel {
  final String id;
  final String roomNumber;
  final int capacity;
  final String? building;
  final String? floor;
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.capacity,
    this.building,
    this.floor,
    required this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      capacity: json['capacity'] ?? 0,
      building: json['building'],
      floor: json['floor'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'capacity': capacity,
      'building': building,
      'floor': floor,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
