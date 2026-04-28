import 'package:flutter_riverpod/legacy.dart';

// state for admin bottom navbar
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

// state for admin AppBar
final notificationCountProvider = StateProvider<int>((ref) => 0);
final adminNameProvider = StateProvider<String>((ref) => "F");
final adminEmailProvider = StateProvider<String>((ref) => "admin@example.com");
final adminIsLoggedInProvider = StateProvider<bool>((ref) => false);
