import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      final user = authProvider.currentUser!;
      
      // Check if device registration is needed for students
      if (user.isStudent && !user.isDeviceRegistered) {
        context.go('/device-registration');
        return;
      }
      
      // Navigate to appropriate dashboard
      switch (user.role) {
        case 'student':
          context.go('/student/dashboard');
          break;
        case 'manager':
          context.go('/manager/dashboard');
          break;
        case 'admin':
          context.go('/admin/dashboard');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60.h),
                
                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.home_work_outlined,
                          size: 40.sp,
                          color: Colors.white,
                        ),
                      ),
                      
                      SizedBox(height: 20.h),
                      
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      Text(
                        'Sign in to your account',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 40.h),
                
                // Email Field
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16.h),
                
                // Password Field
                AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 12.h),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return AuthButton(
                      text: 'Sign In',
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                
                SizedBox(height: 16.h),
                
                // Error Message
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
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                authProvider.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                SizedBox(height: 40.h),
                
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}