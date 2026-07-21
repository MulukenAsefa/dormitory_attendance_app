import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),

            // App Icon
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
              child: Icon(
                Icons.home_work,
                size: 50.sp,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 24.h),

            // App Name
            Text(
              'Dormitory Attendance',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8.h),

            // Version
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: 32.h),

            // Description
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About the App',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Dormitory Attendance is a comprehensive mobile application designed to automate and secure the dormitory attendance process. The app uses GPS geofencing and device binding to prevent proxy attendance and ensure accurate tracking of student presence.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Features
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Features',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildFeatureItem(
                    icon: Icons.location_on,
                    title: 'GPS Geofencing',
                    description: 'Mark attendance only within dormitory boundaries',
                  ),
                  SizedBox(height: 12.h),
                  _buildFeatureItem(
                    icon: Icons.phone_android,
                    title: 'Device Binding',
                    description: 'One registered device per student',
                  ),
                  SizedBox(height: 12.h),
                  _buildFeatureItem(
                    icon: Icons.fingerprint,
                    title: 'Biometric Auth',
                    description: 'Optional fingerprint/face verification',
                  ),
                  SizedBox(height: 12.h),
                  _buildFeatureItem(
                    icon: Icons.history,
                    title: 'Attendance History',
                    description: 'View and track your attendance records',
                  ),
                  SizedBox(height: 12.h),
                  _buildFeatureItem(
                    icon: Icons.notifications,
                    title: 'Smart Notifications',
                    description: 'Reminders and attendance confirmations',
                  ),
                  SizedBox(height: 12.h),
                  _buildFeatureItem(
                    icon: Icons.security,
                    title: 'Secure & Private',
                    description: 'Your data is encrypted and protected',
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Contact & Support
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact & Support',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildContactItem(
                    icon: Icons.email,
                    label: 'Email',
                    value: 'support@dormitory.com',
                    onTap: () => _launchEmail('support@dormitory.com'),
                  ),
                  SizedBox(height: 12.h),
                  _buildContactItem(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: '+1 (555) 123-4567',
                    onTap: () => _launchPhone('+15551234567'),
                  ),
                  SizedBox(height: 12.h),
                  _buildContactItem(
                    icon: Icons.language,
                    label: 'Website',
                    value: 'www.dormitory.com',
                    onTap: () => _launchWebsite('https://www.dormitory.com'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Legal
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildLegalItem(
                    label: 'Privacy Policy',
                    onTap: () {
                      // Navigate to privacy policy
                    },
                  ),
                  Divider(height: 24.h),
                  _buildLegalItem(
                    label: 'Terms of Service',
                    onTap: () {
                      // Navigate to terms of service
                    },
                  ),
                  Divider(height: 24.h),
                  _buildLegalItem(
                    label: 'Open Source Licenses',
                    onTap: () {
                      showLicensePage(context: context);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Copyright
            Text(
              '© 2024 Dormitory Attendance\nAll rights reserved',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: Colors.grey[600],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 20.sp,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
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
            Icons.chevron_right,
            size: 20.sp,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchWebsite(String url) async {
    final Uri webUri = Uri.parse(url);
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}
