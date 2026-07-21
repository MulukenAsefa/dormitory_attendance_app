import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/device_registration_screen.dart';
import '../../features/student/screens/student_dashboard_screen.dart';
import '../../features/student/screens/mark_attendance_screen.dart';
import '../../features/student/screens/attendance_history_screen.dart';
import '../../features/manager/screens/manager_dashboard_screen.dart';
import '../../features/manager/screens/student_list_screen.dart';
import '../../features/manager/screens/attendance_reports_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/user_management_screen.dart';
import '../../features/admin/screens/room_management_screen.dart';
import '../../features/admin/screens/system_settings_screen.dart';
import '../../features/shared/screens/splash_screen.dart';
import '../../features/shared/screens/profile_screen.dart';
import '../../features/shared/screens/about_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final userRole = authProvider.currentUser?.role;
      final currentPath = state.uri.path;
      
      // If not logged in and trying to access protected routes
      if (!isLoggedIn && !_isPublicRoute(currentPath)) {
        return '/login';
      }
      
      // If logged in and trying to access auth routes
      if (isLoggedIn && _isAuthRoute(currentPath)) {
        return _getHomeRouteForRole(userRole);
      }
      
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/device-registration',
        builder: (context, state) => const DeviceRegistrationScreen(),
      ),
      
      // Student Routes
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/student/mark-attendance',
        builder: (context, state) => const MarkAttendanceScreen(),
      ),
      GoRoute(
        path: '/student/attendance-history',
        builder: (context, state) => const AttendanceHistoryScreen(),
      ),
      
      // Manager Routes
      GoRoute(
        path: '/manager/dashboard',
        builder: (context, state) => const ManagerDashboardScreen(),
      ),
      GoRoute(
        path: '/manager/students',
        builder: (context, state) => const StudentListScreen(),
      ),
      GoRoute(
        path: '/manager/reports',
        builder: (context, state) => const AttendanceReportsScreen(),
      ),
      
      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/rooms',
        builder: (context, state) => const RoomManagementScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const SystemSettingsScreen(),
      ),
      
      // Shared Routes
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
  
  static bool _isPublicRoute(String location) {
    const publicRoutes = [
      '/splash',
      '/login',
      '/register',
      '/forgot-password',
    ];
    return publicRoutes.contains(location);
  }
  
  static bool _isAuthRoute(String location) {
    const authRoutes = [
      '/login',
      '/register',
      '/forgot-password',
    ];
    return authRoutes.contains(location);
  }
  
  static String _getHomeRouteForRole(String? role) {
    switch (role) {
      case 'student':
        return '/student/dashboard';
      case 'manager':
        return '/manager/dashboard';
      case 'admin':
        return '/admin/dashboard';
      default:
        return '/login';
    }
  }
}