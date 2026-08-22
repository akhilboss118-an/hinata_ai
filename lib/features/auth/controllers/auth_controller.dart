import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_service.dart';
import 'auth_state.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthInitial());

  /// Checks if an active persistent session already exists
  Future<void> checkAuthState() async {
    state = const AuthLoading(statusMessage: 'Connecting to Hinata...');
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final profile = await _authService.getCurrentUserProfile();
        if (profile != null) {
          state = Authenticated(user: profile);
          return;
        }
      }
      state = const Unauthenticated();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Initiates Google Sign-In flow
  Future<void> signInWithGoogle() async {
    state = const AuthLoading(statusMessage: 'Signing in with Google...');
    try {
      final profile = await _authService.signInWithGoogle();
      state = Authenticated(user: profile);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Signs out and resets state
  Future<void> signOut() async {
    state = const AuthLoading(statusMessage: 'Signing out...');
    try {
      await _authService.signOut();
      state = const Unauthenticated();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
}
