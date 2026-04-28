import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/shared/widgets/admin_bottom_navbar.dart';
import 'package:track_vision/features/auth/screens/login_screen.dart';
import 'package:track_vision/shared/providers/auth_notifier.dart';
import 'package:track_vision/shared/providers/auth_state.dart';
import 'package:track_vision/shared/widgets/user_bottom_navbar.dart';
import 'package:track_vision/core/config/constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid modifying provider during build
    Future.microtask(() => _initializeApp());
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();
    // Load auth state from storage
    await ref.read(authNotifierProvider.notifier).loadFromStorage();

    final elapsed = DateTime.now().difference(startTime);
    final remaining = Duration(seconds: 1) - elapsed;

    if (remaining.inMilliseconds > 0) {
      await Future.delayed(remaining);
    }
    if (!mounted) return;

    // Check auth status and navigate
    final authState = ref.read(authNotifierProvider);

    if (authState.status == AuthStatus.authenticated) {
      // Check if user is admin or regular user
      final userRole = authState.user?.role.toLowerCase() ?? '';
      print('User role detected: $userRole');

      if (userRole == 'admin' || userRole.contains('admin')) {
        print('Navigating to Admin Dashboard');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminBottomNavbar()),
        );
      } else {
        print('Navigating to User Dashboard');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserBottomNavbar()),
        );
      }
    } else {
      // Not authenticated, go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LogIn()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset("assets/images/applogo.png", height: 120, width: 120),
            const SizedBox(height: 20),
            // App Name
            const Text(
              "Track Vision",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Tagline
            const Text(
              "Intelligent Vehicle Monitoring",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
