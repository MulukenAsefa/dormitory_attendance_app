import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/user_model.dart';
import '../../../core/models/attendance_model.dart';
import '../../../core/config/app_config.dart';

class ManagerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<UserModel> _students = [];
  List<AttendanceModel> _todayAttendance = [];
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<UserModel> get students => _students;
  List<AttendanceModel> get todayAttendance => _todayAttendance;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<UserModel> get presentStudents {
    final presentIds = _todayAttendance
        .where((a) => a.isPresent || a.isLate)
        .map((a) => a.userId)
        .toSet();
    return _students.where((s) => presentIds.contains(s.id)).toList();
  }

  List<UserModel> get absentStudents {
    final presentIds = _todayAttendance.map((a) => a.userId).toSet();
    return _students.where((s) => !presentIds.contains(s.id)).toList();
  }

  List<AttendanceModel> get lateStudents {
    return _todayAttendance.where((a) => a.isLate).toList();
  }

  // Load all students
  Future<void> loadStudents() async {
    try {
      _setLoading(true);
      
      final snapshot = await _firestore
          .collection(AppConfig.usersCollection)
          .where('role', isEqualTo: AppConfig.roleStudent)
          .where('isActive', isEqualTo: true)
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

  // Load today's attendance
  Future<void> loadTodayAttendance() async {
    try {
      _setLoading(true);
      
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(AppConfig.attendanceCollection)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      _todayAttendance = snapshot.docs
          .map((doc) => AttendanceModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load today\'s attendance: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load dashboard statistics
  Future<void> loadDashboardStats() async {
    try {
      await loadStudents();
      await loadTodayAttendance();

      final totalStudents = _students.length;
      final presentCount = _todayAttendance.where((a) => a.isPresent).length;
      final lateCount = _todayAttendance.where((a) => a.isLate).length;
      final absentCount = totalStudents - _todayAttendance.length;

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
    }
  }

  // Approve late attendance
  Future<bool> approveLateAttendance({
    required String attendanceId,
    required String approvedBy,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final updates = <String, dynamic>{
        'status': AppConfig.statusPresent,
        'approvedBy': approvedBy,
        'approvedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (notes != null) {
        updates['notes'] = notes;
      }

      await _firestore
          .collection(AppConfig.attendanceCollection)
          .doc(attendanceId)
          .update(updates);

      // Update local list
      final index = _todayAttendance.indexWhere((a) => a.id == attendanceId);
      if (index != -1) {
        _todayAttendance[index] = _todayAttendance[index].copyWith(
          status: AppConfig.statusPresent,
          approvedBy: approvedBy,
          approvedAt: DateTime.now(),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to approve late attendance: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Manual attendance override
  Future<bool> manualAttendanceOverride({
    required String userId,
    required String status,
    required String approvedBy,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Find student
      final student = _students.firstWhere((s) => s.id == userId);

      // Check if attendance already exists
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final existingSnapshot = await _firestore
          .collection(AppConfig.attendanceCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .limit(1)
          .get();

      if (existingSnapshot.docs.isNotEmpty) {
        // Update existing
        await _firestore
            .collection(AppConfig.attendanceCollection)
            .doc(existingSnapshot.docs.first.id)
            .update({
          'status': status,
          'approvedBy': approvedBy,
          'approvedAt': DateTime.now().toIso8601String(),
          'notes': notes,
          'isManualEntry': true,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        // Create new
        final attendance = AttendanceModel(
          id: _firestore.collection(AppConfig.attendanceCollection).doc().id,
          userId: userId,
          userName: student.fullName,
          userEmail: student.email,
          roomId: student.roomId,
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
      }

      await loadTodayAttendance();
      return true;
    } catch (e) {
      _setError('Failed to override attendance: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get attendance by date range
  Future<List<AttendanceModel>> getAttendanceByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? roomId,
  }) async {
    try {
      _setLoading(true);
      
      var query = _firestore
          .collection(AppConfig.attendanceCollection)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String());

      if (roomId != null) {
        query = query.where('roomId', isEqualTo: roomId);
      }

      final snapshot = await query.orderBy('date', descending: true).get();

      return snapshot.docs
          .map((doc) => AttendanceModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      _setError('Failed to load attendance: $e');
      return [];
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