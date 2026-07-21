import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/location_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../admin/providers/admin_provider.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  bool _isChecking = false;
  bool _locationEnabled = false;
  bool _biometricAvailable = false;
  String? _statusMessage;
  Color _statusColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _checkRequirements();
  }

  Future<void> _checkRequirements() async {
    setState(() {
      _isChecking = true;
      _statusMessage = 'Checking requirements...';
    });

    // Request and check location permission
    final locationEnabled = await LocationService.requestLocationPermission();
    
    if (!locationEnabled) {
      setState(() {
        _locationEnabled = false;
        _statusMessage = 'Location permission denied. Please enable location in settings.';
        _statusColor = Colors.red;
        _isChecking = false;
      });
      return;
    }

    // Check if location services are enabled
    final servicesEnabled = await LocationService.isLocationEnabled();
    setState(() {
      _locationEnabled = servicesEnabled;
    });

    // Check biometric
    final biometricAvailable = await BiometricService.isBiometricAvailable();
    setState(() {
      _biometricAvailable = biometricAvailable;
    });

    if (!servicesEnabled) {
      setState(() {
        _statusMessage = 'Location services are disabled. Please enable location.';
        _statusColor = Colors.red;
      });
    } else {
      setState(() {
        _statusMessage = 'Ready to mark attendance';
        _statusColor = Colors.green;
      });
    }

    setState(() {
      _isChecking = false;
    });
  }

  Future<void> _markAttendance() async {
    final authProvider = context.read<AuthProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    final adminProvider = context.read<AdminProvider>();

    final user = authProvider.currentUser;
    if (user == null) {
      _showError('User not found');
      return;
    }

    setState(() {
      _isChecking = true;
      _statusMessage = 'Verifying location...';
    });

    try {
      // Load system settings
      await adminProvider.loadSystemSettings();
      final settings = adminProvider.systemSettings;

      if (settings == null) {
        _showError('System settings not configured');
        return;
      }

      final targetLat = settings['dormLatitude'] as double? ?? 0.0;
      final targetLon = settings['dormLongitude'] as double? ?? 0.0;
      final radius = settings['geofenceRadius'] as double? ?? 100.0;
      final requireBiometric = settings['requireBiometric'] as bool? ?? false;

      // Check biometric if required
      if (requireBiometric && _biometricAvailable) {
        setState(() {
          _statusMessage = 'Authenticating...';
        });

        final authenticated = await BiometricService.authenticate(
          reason: 'Authenticate to mark attendance',
        );

        if (!authenticated) {
          _showError('Biometric authentication failed');
          return;
        }
      }

      // Mark attendance
      setState(() {
        _statusMessage = 'Marking attendance...';
      });

      final success = await attendanceProvider.markAttendance(
        user: user,
        targetLatitude: targetLat,
        targetLongitude: targetLon,
        radius: radius,
      );

      if (success) {
        if (mounted) {
          _showSuccess('Attendance marked successfully!');
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            context.go('/student/dashboard');
          }
        }
      } else {
        _showError(attendanceProvider.errorMessage ?? 'Failed to mark attendance');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _statusMessage = message;
      _statusColor = Colors.red;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    setState(() {
      _statusMessage = message;
      _statusColor = Colors.green;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _statusColor.withOpacity(0.1),
                border: Border.all(
                  color: _statusColor,
                  width: 3,
                ),
              ),
              child: Icon(
                _isChecking
                    ? Icons.hourglass_empty
                    : _locationEnabled
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                size: 60.sp,
                color: _statusColor,
              ),
            ),

            SizedBox(height: 32.h),

            // Status Message
            Text(
              _statusMessage ?? 'Initializing...',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: _statusColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 48.h),

            // Requirements Check
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildRequirementItem(
                    'Location Services',
                    _locationEnabled,
                    Icons.location_on,
                  ),
                  Divider(height: 24.h),
                  _buildRequirementItem(
                    'Biometric Available',
                    _biometricAvailable,
                    Icons.fingerprint,
                  ),
                ],
              ),
            ),

            SizedBox(height: 48.h),

            // Mark Attendance Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isChecking || !_locationEnabled
                    ? null
                    : _markAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
                child: _isChecking
                    ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Mark Attendance',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 16.h),

            // Retry Button
            if (!_locationEnabled)
              TextButton.icon(
                onPressed: _checkRequirements,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            
            // Open Settings Button
            if (!_locationEnabled)
              TextButton.icon(
                onPressed: () async {
                  await Permission.location.request();
                  _checkRequirements();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Grant Permission'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String label, bool status, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: status ? Colors.green : Colors.grey,
          size: 24.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(
          status ? Icons.check_circle : Icons.cancel,
          color: status ? Colors.green : Colors.red,
          size: 20.sp,
        ),
      ],
    );
  }
}