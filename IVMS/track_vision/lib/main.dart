import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_vision/features/admin/alerts/screens/admin_alerts_screen.dart';
import 'package:track_vision/shared/widgets/admin_bottom_navbar.dart';
import 'package:track_vision/features/admin/dashboard/screens/admin_dashboard_screen.dart';
import 'package:track_vision/features/admin/vehicles/screens/admin_vehicles_screen.dart';
import 'package:track_vision/features/admin/vehicles/screens/admin_unknown_vehicles_screen.dart';
import 'package:track_vision/features/auth/screens/forgot_password_screen.dart';
import 'package:track_vision/features/auth/screens/login_screen.dart';
import 'package:track_vision/features/auth/screens/reset_password_screen.dart';
import 'package:track_vision/features/auth/screens/signup_screen.dart';
import 'package:track_vision/features/auth/screens/splash_screen.dart';
import 'package:track_vision/features/auth/screens/verify_code_screen.dart';
import 'package:track_vision/features/auth/providers/mobile_camerastate.dart';
import 'package:track_vision/shared/widgets/not_found_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // wire up Riverpod
  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track Vision',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login/':
            return MaterialPageRoute(builder: (_) => const LogIn());
          case '/signup/':
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUp());
          case '/forgot-password/':
            return MaterialPageRoute(builder: (_) => const ForgotPassword());
          case '/verify-code/':
            final email = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => VerifyCode(email: email));
          case '/new-password/':
            return MaterialPageRoute(builder: (_) => const NewPassword());
          // Admin page routed
          case '/admin-dashboard/':
            return MaterialPageRoute(builder: (_) => const AdminDashboard());
          case '/admin-vehicles/':
            return MaterialPageRoute(builder: (_) => const AdminVehicles());
          case '/admin-unknown-vehicles/':
            return MaterialPageRoute(
              builder: (_) => const AdminUnknownVehiclesScreen(),
            );
          case '/admin_alerts/':
            return MaterialPageRoute(builder: (_) => const AdminAlerts());
          case '/admin-bottomNavbar/':
            return MaterialPageRoute(builder: (_) => const AdminBottomNavbar());
          default:
            // Return 404 page for unknown routes
            return MaterialPageRoute(
              builder: (_) => NotFoundPage(routeName: settings.name),
            );
        }
      },
    );
  }
}
