import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/models/attendance_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../attendance/providers/attendance_provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final authProvider = context.read<AuthProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    
    if (authProvider.currentUser != null) {
      await attendanceProvider.loadAttendanceHistory(
        authProvider.currentUser!.id,
        limit: 60,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, child) {
          if (attendanceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final attendances = attendanceProvider.attendanceList;

          if (attendances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No attendance history',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadHistory,
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: attendances.length,
              itemBuilder: (context, index) {
                final attendance = attendances[index];
                return _buildAttendanceCard(attendance);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceModel attendance) {
    Color statusColor;
    IconData statusIcon;

    switch (attendance.status) {
      case 'present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'late':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'excused':
        statusColor = Colors.blue;
        statusIcon = Icons.info;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM dd, yyyy').format(attendance.date),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        attendance.statusDisplayName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (attendance.checkInTime != null) ...[
              SizedBox(height: 12.h),
              Divider(),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Check-in: ${DateFormat('HH:mm').format(attendance.checkInTime!)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
            if (attendance.address != null) ...[
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      attendance.address!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (attendance.isManualEntry) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Manual Entry',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}