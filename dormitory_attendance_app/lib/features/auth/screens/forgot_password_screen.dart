import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.resetPassword(_emailController.text.trim());

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                
                Icon(
                  Icons.lock_reset,
                  size: 80.sp,
                  color: Theme.of(context).primaryColor,
                ),
                
                SizedBox(height: 24.h),
                
                Text(
                  'Forgot Password?',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 8.h),
                
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 32.h),
                
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
                
                SizedBox(height: 24.h),
                
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return AuthButton(
                      text: 'Send Reset Link',
                      onPressed: authProvider.isLoading ? null : _handleResetPassword,
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
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                const Spacer(),
                
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Back to Sign In',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}