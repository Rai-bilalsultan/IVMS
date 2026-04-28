// Example: How to set user data after login
// Add this code in your login success handler

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/features/auth/providers/user_provider.dart';

// ============================================
// LOGIN: Set user data after successful login
// ============================================
void setUserDataAfterLogin(WidgetRef ref, Map<String, dynamic> userData) {
  // Set user name from login response
  if (userData['fullName'] != null) {
    ref.read(uUserNameProvider.notifier).state = userData['fullName'];
  }

  // Set user email from login response
  if (userData['email'] != null) {
    ref.read(uUserEmailProvider.notifier).state = userData['email'];
  }

  // Set login status to true
  ref.read(uIsLoggedInProvider.notifier).state = true;
}

// ============================================
// LOGOUT: Clear all user data
// ============================================
void performLogout(WidgetRef ref, BuildContext context) {
  // Clear user name
  ref.read(uUserNameProvider.notifier).state = "U";

  // Clear user email
  ref.read(uUserEmailProvider.notifier).state = "user@example.com";

  // Set login status to false
  ref.read(uIsLoggedInProvider.notifier).state = false;

  // Clear notifications
  ref.read(uNotificationCountProvider.notifier).state = 0;

  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Logged out successfully!'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );

  // Navigate back to login
  Navigator.of(context).pushNamedAndRemoveUntil(
    '/login/', // Your app uses routes with trailing slash
    (Route<dynamic> route) => false,
  );
}

// ============================================
// USAGE EXAMPLES
// ============================================

// IN LOGIN SCREEN:
/*
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void _handleLogin(WidgetRef ref, BuildContext context) async {
    // Your login API call
    final response = await loginApi(email, password);
    
    if (response.success) {
      // Set user data after successful login
      setUserDataAfterLogin(ref, response.data);
      
      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.error)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () => _handleLogin(ref, context),
        child: const Text('Login'),
      ),
    );
  }
}
*/

// IN LOGOUT (PROFILE DROPDOWN):
/*
void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            performLogout(ref, context);
          },
          child: const Text('Logout'),
        ),
      ],
    ),
  );
  */
