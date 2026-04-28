import 'package:flutter/material.dart';
import 'package:track_vision/features/auth/screens/login_screen.dart';
import 'package:track_vision/features/auth/screens/signup_screen.dart';
import 'package:track_vision/features/auth/screens/forgot_password_screen.dart';
import 'package:track_vision/features/auth/screens/verify_code_screen.dart';
import 'package:track_vision/features/auth/screens/reset_password_screen.dart';
import 'package:track_vision/features/auth/screens/splash_screen.dart';
import 'package:track_vision/shared/widgets/user_bottom_navbar.dart';
import 'package:track_vision/shared/widgets/admin_bottom_navbar.dart';

/// Application route names
class AppRoutes {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String verifyCode = '/verify-code';
  static const String resetPassword = '/reset-password';

  // User Routes
  static const String userDashboard = '/user/dashboard';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
}

/// Generate routes for the application
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LogIn());

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUp());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPassword());

      case AppRoutes.verifyCode:
        final email = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => VerifyCode(email: email ?? ''),
        );

      case AppRoutes.resetPassword:
        return MaterialPageRoute(builder: (_) => const NewPassword());

      case AppRoutes.userDashboard:
        return MaterialPageRoute(builder: (_) => const UserBottomNavbar());

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminBottomNavbar());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
