import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';

class DeviceRegistrationScreen extends StatefulWidget {
  const DeviceRegistrationScreen({super.key});

  @override
  State<DeviceRegistrationScreen> createState() => _DeviceRegistrationScreenState();
}

class _DeviceRegistrationScreenState extends State<DeviceRegistrationScreen> {
  Future<void> _handleDeviceRegistration() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.registerDevice();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device registered successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/student/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_android,
                size: 100.sp,
                color: Theme.of(context).primaryColor,
              ),
              
              SizedBox(height: 32.h),
              
              Text(
                'Register Your Device',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16.h),
              
              Text(
                'For security purposes, you need to register this device to mark attendance. This device will be linked to your account.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 48.h),
              
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return AuthButton(
                    text: 'Register This Device',
                    onPressed: authProvider.isLoading ? null : _handleDeviceRegistration,
                    isLoading: authProvider.isLoading,
                  );
                },
              ),
              
              SizedBox(height: 16.h),
              
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.errorMessage != null) {
                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        authProvider.errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}