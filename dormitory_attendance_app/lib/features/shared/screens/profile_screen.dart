import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user == null) return;

    final success = await authProvider.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
    );

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Avatar
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 60.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Name
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Role Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Profile Information
                  _buildInfoCard(
                    children: [
                      _buildInfoItem(
                        icon: Icons.email,
                        label: 'Email',
                        value: user.email,
                      ),
                      Divider(height: 32.h),
                      if (_isEditing) ...[
                        _buildEditableField(
                          controller: _firstNameController,
                          label: 'First Name',
                          icon: Icons.person_outline,
                        ),
                        SizedBox(height: 16.h),
                        _buildEditableField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          icon: Icons.person_outline,
                        ),
                        SizedBox(height: 16.h),
                        _buildEditableField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ] else ...[
                        _buildInfoItem(
                          icon: Icons.person_outline,
                          label: 'First Name',
                          value: user.firstName,
                        ),
                        Divider(height: 32.h),
                        _buildInfoItem(
                          icon: Icons.person_outline,
                          label: 'Last Name',
                          value: user.lastName,
                        ),
                        Divider(height: 32.h),
                        _buildInfoItem(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: user.phoneNumber ?? 'Not provided',
                        ),
                      ],
                      if (user.role == 'student') ...[
                        Divider(height: 32.h),
                        _buildInfoItem(
                          icon: Icons.meeting_room,
                          label: 'Room',
                          value: user.roomId ?? 'Not assigned',
                        ),
                      ],
                      Divider(height: 32.h),
                      _buildInfoItem(
                        icon: Icons.phone_android,
                        label: 'Device Status',
                        value: user.isDeviceRegistered 
                            ? 'Registered' 
                            : 'Not Registered',
                        valueColor: user.isDeviceRegistered 
                            ? Colors.green 
                            : Colors.orange,
                      ),
                    ],
                  ),

                  if (_isEditing) ...[
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _firstNameController.text = user.firstName;
                                _lastNameController.text = user.lastName;
                                _phoneController.text = user.phoneNumber ?? '';
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _handleSave,
                            child: authProvider.isLoading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 24.h),

                  // Action Buttons
                  _buildActionButton(
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: () => context.push('/about'),
                  ),

                  SizedBox(height: 12.h),

                  _buildActionButton(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () => context.push('/forgot-password'),
                  ),

                  SizedBox(height: 12.h),

                  _buildActionButton(
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: _handleLogout,
                    color: Colors.red,
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
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
        children: children,
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24.sp,
          color: Colors.grey[600],
        ),
        SizedBox(width: 16.w),
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
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (label.contains('Name') && (value == null || value.isEmpty)) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? Colors.grey[700],
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: color ?? Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'manager':
        return Colors.blue;
      case 'student':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}