import '../models/user_profile.dart';

/// Sealed class representing the reactive authentication state
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? statusMessage;
  const AuthLoading({this.statusMessage});
}

class Authenticated extends AuthState {
  final UserProfile user;
  final bool isFirstLogin;

  const Authenticated({
    required this.user,
    this.isFirstLogin = false,
  });
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
