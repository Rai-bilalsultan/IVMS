import 'package:track_vision/features/auth/models/admin_model.dart';
import 'package:track_vision/features/auth/models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final AdminModel? admin;
  final String? access;
  final String? refresh;
  final String? message;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.admin,
    this.access,
    this.refresh,
    this.message,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    AdminModel? admin,
    String? access,
    String? refresh,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      admin: admin ?? this.admin,
      access: access ?? this.access,
      refresh: refresh ?? this.refresh,
      message: message ?? this.message,
    );
  }
}
