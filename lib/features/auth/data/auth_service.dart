import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

/// Production-grade Service managing Google Sign-In and Firebase Authentication with Firestore synchronization
class AuthService {
  final FirebaseAuth? _customAuth;
  final GoogleSignIn? _customGoogleSignIn;
  final FirebaseFirestore? _customFirestore;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _customAuth = auth,
        _customGoogleSignIn = googleSignIn,
        _customFirestore = firestore;

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  GoogleSignIn get _googleSignIn =>
      _customGoogleSignIn ??
      GoogleSignIn(
        scopes: const ['email', 'profile'],
      );

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges {
    final auth = _auth;
    if (auth != null) {
      return auth.authStateChanges();
    }
    return Stream.value(null);
  }

  /// Currently logged in Firebase user
  User? get currentUser => _auth?.currentUser;

  /// Retrieves the current user's Firebase ID Token for backend API verification
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    final user = currentUser;
    if (user == null) return null;
    return await user.getIdToken(forceRefresh);
  }

  /// Performs Google Sign-In across Web and Mobile with Firestore profile synchronization
  Future<UserProfile?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      debugPrint('Firebase Auth not available; returning preview user profile.');
      return _generatePreviewProfile();
    }

    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Web: Use GoogleAuthProvider with signInWithPopup
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        userCredential = await auth.signInWithPopup(googleProvider);
      } else {
        // Mobile (Android / iOS): Use google_sign_in package
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          // User aborted the sign-in flow
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await auth.signInWithCredential(credential);
      }

      final User? user = userCredential.user;
      if (user != null) {
        final isNewUser =
            userCredential.additionalUserInfo?.isNewUser ?? false;
        return await _syncUserProfile(user, isNewUser: isNewUser);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception [${e.code}]: ${e.message}');
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Performs Email and Password Sign-In
  Future<UserProfile?> signInWithEmailPassword(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      return _generatePreviewProfile();
    }

    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        return await _syncUserProfile(user);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Email Sign-In Exception [${e.code}]: ${e.message}');
      throw _mapFirebaseAuthError(e);
    }
  }

  /// Registers a new user with Email and Password
  Future<UserProfile?> signUpWithEmailPassword(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      return _generatePreviewProfile();
    }

    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        return await _syncUserProfile(user, isNewUser: true);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Email Sign-Up Exception [${e.code}]: ${e.message}');
      throw _mapFirebaseAuthError(e);
    }
  }

  /// Synchronizes or creates user document at /users/{uid} in Firestore
  Future<UserProfile> _syncUserProfile(User user, {bool isNewUser = false}) async {
    final now = DateTime.now();
    final firestore = _firestore;

    if (firestore != null) {
      try {
        final userDocRef = firestore.collection('users').doc(user.uid);
        final docSnap = await userDocRef.get();

        if (isNewUser || !docSnap.exists) {
          // First-time user creation
          final newProfileData = {
            'uid': user.uid,
            'displayName': user.displayName ?? 'Friend',
            'email': user.email ?? '',
            'photoUrl': user.photoURL,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'lastSeenAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'timezone': DateTime.now().timeZoneName,
            'role': 'user',
            'isProfileComplete': false,
          };

          await userDocRef.set(newProfileData, SetOptions(merge: true));

          return UserProfile(
            uid: user.uid,
            displayName: user.displayName ?? 'Friend',
            email: user.email ?? '',
            photoUrl: user.photoURL,
            createdAt: now,
            lastSeenAt: now,
            timezone: DateTime.now().timeZoneName,
          );
        } else {
          // Existing user: Update last active timestamp and profile data
          final existingData = docSnap.data() ?? {};
          await userDocRef.set({
            'lastSeenAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'displayName': user.displayName ?? existingData['displayName'] ?? 'Friend',
            'photoUrl': user.photoURL ?? existingData['photoUrl'],
            'photoURL': user.photoURL ?? existingData['photoURL'],
          }, SetOptions(merge: true));

          return UserProfile.fromMap(existingData, user.uid);
        }
      } catch (e) {
        debugPrint('Firestore sync notice (fallback to local profile): $e');
      }
    }

    return UserProfile(
      uid: user.uid,
      displayName: user.displayName ?? 'Friend',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: now,
      lastSeenAt: now,
      timezone: DateTime.now().timeZoneName,
    );
  }

  /// Retrieves user profile from Firestore for the current active session
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final firestore = _firestore;
    if (firestore != null) {
      try {
        final docSnap = await firestore.collection('users').doc(user.uid).get();
        if (docSnap.exists && docSnap.data() != null) {
          return UserProfile.fromMap(docSnap.data()!, user.uid);
        }
      } catch (e) {
        debugPrint('Firestore fetch notice: $e');
      }
    }

    return UserProfile(
      uid: user.uid,
      displayName: user.displayName ?? 'Friend',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastSeenAt: DateTime.now(),
      timezone: DateTime.now().timeZoneName,
    );
  }

  /// Signs out from Firebase and Google Sign-In
  Future<void> signOut() async {
    try {
      await Future.wait([
        if (_auth != null) _auth!.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('Sign out notice: $e');
    }
  }

  UserProfile _generatePreviewProfile() {
    final now = DateTime.now();
    return UserProfile(
      uid: currentUser?.uid ?? 'hinata_user_preview_1',
      displayName: currentUser?.displayName ?? 'Alex',
      email: currentUser?.email ?? 'alex@hinata.ai',
      photoUrl: currentUser?.photoURL,
      createdAt: now,
      lastSeenAt: now,
      timezone: DateTime.now().timeZoneName,
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email using a different provider.';
      case 'invalid-credential':
        return 'The Google credentials provided were invalid or expired.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      case 'popup-closed-by-user':
        return 'Sign-in popup was closed before completing.';
      default:
        return e.message ?? 'An error occurred during authentication.';
    }
  }
}
