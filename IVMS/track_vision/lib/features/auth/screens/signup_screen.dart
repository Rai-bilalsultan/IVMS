import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/shared/providers/auth_notifier.dart';
import 'package:track_vision/shared/providers/auth_state.dart';

import 'package:track_vision/core/config/constants.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  final _formKey = GlobalKey<FormState>();
  // Common fields for Admin and user
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // User-only fields
  final TextEditingController _cnicNumber = TextEditingController();

  // Admin-only fields
  final TextEditingController _organizationName = TextEditingController();
  final TextEditingController _organizationCode = TextEditingController();

  // User or Admin role selection
  String _selectedRole = 'User';

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phoneNumber.dispose();
    _password.dispose();
    _cnicNumber.dispose();
    _organizationName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    if (_selectedRole == 'User') {
      final payload = {
        'fullName': _fullName.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text.trim(),
        'cnic': _cnicNumber.text.trim(),
        'phone_number': _phoneNumber.text.trim(),
        'role': 'user',
      };

      await authNotifier.signupUser(payload);
    } else {
      final payload = {
        'fullName': _fullName.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text.trim(),
        'phone_number': _phoneNumber.text.trim(),
        'organizationName': _organizationName.text.trim(),
        'organizationCode': _organizationCode.text.trim(),
        'role': 'admin',
      };
      await authNotifier.signupAdmin(payload);
    }

    //read update state after the async call
    final authState = ref.read(authNotifierProvider);
    if (!mounted) return;

    if (authState.status != AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedRole == 'User'
                ? 'User signed up successfully!'
                : 'Admin signed up successfully!',
          ),
        ),
      );
      Navigator.pushNamed(context, '/login');
    } else if (authState.message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authState.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                const Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Create",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDarkMode,
                            ),
                          ),
                          //
                          Text(
                            "Account",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Fill your Information below or",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                // Select Role dropdown
                const Text(
                  "Select Role",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDarkMode,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'User', child: Text("User")),
                    DropdownMenuItem(
                      value: 'Admin(Organization)',
                      child: Text("Admin(Organization)"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // full Name text form Field
                TextFormField(
                  controller: _fullName,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Full Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Email';
                    }
                    final emailRegex = RegExp(
                      r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone Number
                TextFormField(
                  controller: _phoneNumber,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Admin vs User specific fields
                if (_selectedRole == 'Admin(Organization)') ...[
                  // Organization Name
                  TextFormField(
                    controller: _organizationName,
                    decoration: const InputDecoration(
                      labelText: 'Organization Name',
                      prefixIcon: Icon(Icons.business_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter organization name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Organization Code
                  TextFormField(
                    controller: _organizationCode,
                    decoration: const InputDecoration(
                      labelText: 'Organization Code',
                      prefixIcon: Icon(Icons.code_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter organization code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  // CNIC for User
                  TextFormField(
                    controller: _cnicNumber,
                    decoration: const InputDecoration(
                      labelText: 'CNIC',
                      hintText: '12345-1234567-1',
                      prefixIcon: Icon(Icons.credit_card_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your CNIC Number';
                      }
                      final cnicRegExp = RegExp(r'^\d{5}-\d{7}-\d{1}$');
                      if (!cnicRegExp.hasMatch(value)) {
                        return 'Enter valid CNIC (e.g. 12345-1234567-1)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Password
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50),
                // Signup Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    child: authState.status == AuthStatus.loading
                        ? const CircularProgressIndicator(
                            color: AppColors.textLightMode,
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLightMode,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text("LogIn here"),
                    ),

                    //Toggle button for admin Signed up
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
