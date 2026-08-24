import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_service.dart';
import '../models/user_profile.dart';
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
      if (profile != null) {
        state = Authenticated(user: profile);
      } else {
        // User cancelled Google sign-in dialog
        state = const Unauthenticated();
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Initiates Email & Password Sign-In flow
  Future<void> signInWithEmailPassword(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      state = const AuthError('Please enter both email and password.');
      return;
    }
    state = const AuthLoading(statusMessage: 'Signing in...');
    try {
      final profile = await _authService.signInWithEmailPassword(email, password);
      if (profile != null) {
        state = Authenticated(user: profile);
      } else {
        state = const Unauthenticated();
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Initiates Email & Password Sign-Up flow
  Future<void> signUpWithEmailPassword(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      state = const AuthError('Please enter both email and password.');
      return;
    }
    state = const AuthLoading(statusMessage: 'Creating account...');
    try {
      final profile = await _authService.signUpWithEmailPassword(email, password);
      if (profile != null) {
        state = Authenticated(user: profile);
      } else {
        state = const Unauthenticated();
      }
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

  /// Enters instant guest / preview session
  void continueAsGuest() {
    final now = DateTime.now();
    state = Authenticated(
      user: UserProfile(
        uid: 'hinata_guest_user',
        displayName: 'Peter',
        email: 'peter@hinata.ai',
        createdAt: now,
        lastSeenAt: now,
        timezone: now.timeZoneName,
      ),
    );
  }
}

