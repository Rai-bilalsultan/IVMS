import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/shared/providers/auth_notifier.dart';
import 'package:track_vision/shared/providers/auth_state.dart';

import 'package:track_vision/core/config/constants.dart';

class NewPassword extends ConsumerStatefulWidget {
  const NewPassword({super.key});

  @override
  ConsumerState<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends ConsumerState<NewPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
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
                    "New",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDarkMode,
                    ),
                  ),
                  //
                  const Text(
                    "Password",
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
                "Now you can create new password",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              const Text(
                "and confirm it below",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 100),
              // new Password text field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'New password',
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
                controller: _newPassword,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter new password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              // Confirm Password Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
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
                controller: _confirmPassword,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm password';
                  } else if (value != _newPassword.text) {
                    return 'Password fo not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50.0),
              // Send Code Button
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authNotifier.resetPassword(
                        _newPassword.text.trim(),
                        _confirmPassword.text.trim(),
                      );
                      if (authState.status != AuthStatus.error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Password reset successful!")),
                        );
                        Navigator.pushNamed(context, '/login');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  child: authState.status == AuthStatus.loading
                      ? const CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        )
                      : const Text(
                          "Confirm New Password",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLightMode,
                          ),
                        ),
                ),
              ),
              if (authState.message != null)
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    authState.message!,
                    style: TextStyle(
                      color: authState.status == AuthStatus.error
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
