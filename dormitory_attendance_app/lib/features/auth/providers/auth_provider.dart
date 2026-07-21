import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/device_service.dart';
import '../../../core/config/app_config.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection(AppConfig.usersCollection).doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromJson({
          'id': doc.id,
          ...doc.data()!,
        });
        
        // Update last login time
        await _updateLastLogin();
        
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        
        // Verify device if user is a student
        if (_currentUser?.isStudent == true) {
          final isDeviceValid = await _verifyDevice();
          if (!isDeviceValid) {
            await signOut();
            _setError('Device not registered or invalid. Please contact administrator.');
            return false;
          }
        }
        
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Sign in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? phoneNumber,
    String? roomId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document
        final userData = UserModel(
          id: credential.user!.uid,
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
            .doc(credential.user!.uid)
            .set(userData.toJson());

        // Send email verification
        await credential.user!.sendEmailVerification();

        _currentUser = userData;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Sign up failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Password reset failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerDevice() async {
    try {
      if (_currentUser == null) return false;

      _setLoading(true);
      _clearError();

      final deviceId = await DeviceService.getDeviceId();
      final deviceInfo = await DeviceService.getDeviceInfo();
      final deviceSecurity = await DeviceService.getDeviceSecurityInfo();

      // Check if device is already registered to another user
      final existingDevice = await _firestore
          .collection(AppConfig.devicesCollection)
          .where('deviceId', isEqualTo: deviceId)
          .where('userId', isNotEqualTo: _currentUser!.id)
          .get();

      if (existingDevice.docs.isNotEmpty) {
        _setError('Device is already registered to another user');
        return false;
      }

      // Register device
      await _firestore
          .collection(AppConfig.devicesCollection)
          .doc(deviceId)
          .set({
        'deviceId': deviceId,
        'userId': _currentUser!.id,
        'userEmail': _currentUser!.email,
        'deviceInfo': deviceInfo,
        'securityInfo': deviceSecurity,
        'isActive': true,
        'registeredAt': DateTime.now().toIso8601String(),
      });

      // Update user document
      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(_currentUser!.id)
          .update({
        'deviceId': deviceId,
        'isDeviceRegistered': true,
      });

      _currentUser = _currentUser!.copyWith(
        deviceId: deviceId,
        isDeviceRegistered: true,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Device registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _verifyDevice() async {
    try {
      if (_currentUser?.deviceId == null) return false;

      final currentDeviceId = await DeviceService.getDeviceId();
      final isIntegrityValid = await DeviceService.validateDeviceIntegrity();

      return _currentUser!.deviceId == currentDeviceId && isIntegrityValid;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Sign out failed: $e');
    }
  }

  Future<void> _updateLastLogin() async {
    if (_currentUser == null) return;

    try {
      await _firestore
          .collection(AppConfig.usersCollection)
          .doc(_currentUser!.id)
          .update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silent fail for last login update
      if (kDebugMode) {
        print('Failed to update last login: $e');
      }
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      if (_currentUser == null) return false;

      _setLoading(true);
      _clearError();

      final updates = <String, dynamic>{};
      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

      if (updates.isNotEmpty) {
        updates['updatedAt'] = DateTime.now().toIso8601String();

        await _firestore
            .collection(AppConfig.usersCollection)
            .doc(_currentUser!.id)
            .update(updates);

        _currentUser = _currentUser!.copyWith(
          firstName: firstName ?? _currentUser!.firstName,
          lastName: lastName ?? _currentUser!.lastName,
          phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
          profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        );

        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Profile update failed: $e');
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

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}