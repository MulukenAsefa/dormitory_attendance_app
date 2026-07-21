import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/manager_provider.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final managerProvider = context.read<ManagerProvider>();
    await managerProvider.loadDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
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
      body: Consumer<ManagerProvider>(
        builder: (context, managerProvider, child) {
          if (managerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = managerProvider.dashboardStats;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  if (stats != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Students',
                            stats['totalStudents'].toString(),
                            Icons.people,
                            Colors.blue,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildStatCard(
                            'Present',
                            stats['presentCount'].toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Late',
                            stats['lateCount'].toString(),
                            Icons.access_time,
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildStatCard(
                            'Absent',
                            stats['absentCount'].toString(),
                            Icons.cancel,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
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
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Attendance Rate',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '${stats['attendanceRate']}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

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
                          'Student List',
                          Icons.list,
                          Colors.blue,
                          () => context.go('/manager/student-list'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          'Reports',
                          Icons.assessment,
                          Colors.purple,
                          () => context.go('/manager/reports'),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Late Students Section
                  if (managerProvider.lateStudents.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Late Students',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () => context.go('/manager/student-list'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ...managerProvider.lateStudents.take(5).map((attendance) {
                      return Card(
                        margin: EdgeInsets.only(bottom: 8.h),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[100],
                            child: Icon(
                              Icons.access_time,
                              color: Colors.orange[700],
                            ),
                          ),
                          title: Text(attendance.userName),
                          subtitle: Text(attendance.userEmail),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 32.sp,
          ),
          SizedBox(height: 12.h),
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
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}