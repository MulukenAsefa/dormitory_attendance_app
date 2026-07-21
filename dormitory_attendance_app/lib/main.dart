import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_options.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/attendance/providers/attendance_provider.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/manager/providers/manager_provider.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase Messaging (not supported on web)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  
  // Initialize Notifications
  await NotificationService.initialize();
  
  runApp(const DormitoryAttendanceApp());
}

class DormitoryAttendanceApp extends StatelessWidget {
  const DormitoryAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => AttendanceProvider()),
            ChangeNotifierProvider(create: (_) => AdminProvider()),
            ChangeNotifierProvider(create: (_) => ManagerProvider()),
          ],
          child: MaterialApp.router(
            title: 'Dormitory Attendance',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}