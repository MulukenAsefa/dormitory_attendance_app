import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../../attendance/providers/attendance_provider.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    
    if (authProvider.currentUser != null) {
      await attendanceProvider.loadTodayAttendance(authProvider.currentUser!.id);
      await attendanceProvider.loadAttendanceStats(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, AttendanceProvider>(
        builder: (context, authProvider, attendanceProvider, child) {
          final user = authProvider.currentUser;
          final todayAttendance = attendanceProvider.todayAttendance;
          final stats = attendanceProvider.attendanceStats;
          
          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          user?.fullName ?? 'Student',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Room: ${user?.roomId ?? 'Not Assigned'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Today's Status
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: todayAttendance != null 
                          ? Colors.green[50] 
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: todayAttendance != null 
                            ? Colors.green[200]! 
                            : Colors.orange[200]!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              todayAttendance != null 
                                  ? Icons.check_circle 
                                  : Icons.warning_amber_rounded,
                              color: todayAttendance != null 
                                  ? Colors.green[700] 
                                  : Colors.orange[700],
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Today\'s Status',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    todayAttendance != null
                                        ? 'Marked as ${todayAttendance.statusDisplayName} at ${DateFormat('HH:mm').format(todayAttendance.checkInTime!)}'
                                        : 'Not marked yet',
                                    style: TextStyle(
                                      color: todayAttendance != null 
                                          ? Colors.green[700] 
                                          : Colors.orange[700],
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          'Mark Attendance',
                          Icons.check_circle_outline,
                          Colors.green,
                          todayAttendance == null,
                          () => context.go('/student/mark-attendance'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          'View History',
                          Icons.history,
                          Colors.blue,
                          true,
                          () => context.go('/student/attendance-history'),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Monthly Statistics
                  if (stats != null) ...[
                    Text(
                      'This Month',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Present',
                                stats['presentDays'].toString(),
                                Colors.green,
                              ),
                              _buildStatItem(
                                'Late',
                                stats['lateDays'].toString(),
                                Colors.orange,
                              ),
                              _buildStatItem(
                                'Absent',
                                stats['absentDays'].toString(),
                                Colors.red,
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Divider(),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Attendance Rate: ',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${stats['attendanceRate']}%',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    bool enabled,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 32.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}