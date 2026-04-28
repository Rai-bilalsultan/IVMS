import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/shared/widgets/admin_bottom_navbar.dart';
import 'package:track_vision/shared/providers/auth_notifier.dart';
import 'package:track_vision/shared/providers/auth_state.dart';
import 'package:track_vision/shared/widgets/user_bottom_navbar.dart';
import 'package:track_vision/core/config/constants.dart';
import 'package:track_vision/core/services/api_service.dart';
import 'package:track_vision/features/auth/providers/user_provider.dart';

class LogIn extends ConsumerStatefulWidget {
  const LogIn({super.key});

  @override
  ConsumerState<LogIn> createState() => _LogInState();
}

class _LogInState extends ConsumerState<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String _deriveNameFromEmail(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return 'User';

    final tokens = local
        .split(RegExp(r'[._-]+'))
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (tokens.isEmpty) return 'User';

    return tokens
        .map(
          (part) =>
              part[0].toUpperCase() +
              (part.length > 1 ? part.substring(1) : ''),
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      // Sign In Page UI/body
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Log",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDarkMode,
                    ),
                  ),
                  //
                  const Text(
                    "In",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              const Text(
                "Welcome back, login to your account!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 50),
              // Email text field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.textDarkMode,
                  ),
                  prefixIcon: Icon(Icons.email_outlined, size: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              // Password Text Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.textDarkMode,
                  ),
                  prefixIcon: Icon(Icons.lock_outlined, size: 20.0),
                  suffixIcon: Icon(Icons.visibility_off_outlined, size: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                obscureText: true,
                controller: _password,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              // forgot Password button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              // Sign In Button
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authNotifier.login(
                        _email.text.trim(),
                        _password.text.trim(),
                      );

                      // Read the *updated* state after login
                      final newState = ref.read(authNotifierProvider);

                      if (newState.status == AuthStatus.authenticated &&
                          newState.user != null) {
                        final role = newState.user!.role;

                        final apiName = newState.user!.full_Name?.trim() ?? '';
                        final apiEmail = newState.user!.email?.trim() ?? '';
                        final inputEmail = _email.text.trim();

                        final displayEmail = apiEmail.isNotEmpty
                            ? apiEmail
                            : inputEmail;
                        final displayName = apiName.isNotEmpty
                            ? apiName
                            : _deriveNameFromEmail(displayEmail);

                        // Set user data in Riverpod state for profile
                        ref.read(uUserNameProvider.notifier).state =
                            displayName;
                        ref.read(uUserEmailProvider.notifier).state =
                            displayEmail;
                        ref.read(uIsLoggedInProvider.notifier).state = true;

                        // Store user email in API service for complaints
                        AuthServices.setUserEmail(displayEmail);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Login successful!")),
                        );

                        // Navigate based on role
                        if (role == 'admin') {
                          // Admin: go to admin dashboard / bottom navbar
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminBottomNavbar(),
                            ),
                          );
                          // or '/admin-bottomNavbar/' if that’s your main admin screen
                        } else {
                          // User: go to user dashboard
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserBottomNavbar(),
                            ),
                          );
                          // or define a named route '/user-dashboard/' and use pushReplacementNamed
                        }
                      } else if (newState.status == AuthStatus.error) {
                        // Optionally show error from authState
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(newState.message ?? 'Login failed'),
                          ),
                        );
                      }
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  child: authState.status == AuthStatus.loading
                      ? const CircularProgressIndicator(
                          color: AppColors.backgroundLight,
                        )
                      : const Text(
                          "Log In",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLightMode,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 10),
              // Already have an account text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text("Signup Now"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
