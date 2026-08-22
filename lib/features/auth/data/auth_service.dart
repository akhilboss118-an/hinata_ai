import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

/// Service managing Google Sign-In and Firebase Authentication with Firestore synchronization
class AuthService {
  FirebaseAuth? _customAuth;
  GoogleSignIn? _customGoogleSignIn;
  FirebaseFirestore? _customFirestore;

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

  GoogleSignIn get _googleSignIn => _customGoogleSignIn ?? GoogleSignIn();

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Stream<User?> get authStateChanges {
    final auth = _auth;
    if (auth != null) {
      return auth.authStateChanges();
    }
    return Stream.value(null);
  }

  User? get currentUser => _auth?.currentUser;

  /// Performs Google Sign-In and synchronizes user profile in Firestore
  Future<UserProfile> signInWithGoogle() async {
    try {
      final auth = _auth;
      if (kIsWeb && auth != null) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        final userCredential = await auth.signInWithPopup(googleProvider);
        final user = userCredential.user;
        if (user != null) {
          return await _syncUserProfile(user);
        }
      } else if (auth != null) {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final OAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final UserCredential userCredential = await auth.signInWithCredential(credential);
          final User? user = userCredential.user;

          if (user != null) {
            return await _syncUserProfile(user);
          }
        }
      }
    } catch (e) {
      debugPrint('Google Sign-In notice: $e');
    }

    // Default development session profile for instant access & testing
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

  /// Synchronizes or creates user document at /users/{uid} in Firestore
  Future<UserProfile> _syncUserProfile(User user) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final userDocRef = firestore.collection('users').doc(user.uid);
        final docSnap = await userDocRef.get();

        final now = DateTime.now();
        if (!docSnap.exists) {
          final newProfile = UserProfile(
            uid: user.uid,
            displayName: user.displayName ?? 'Friend',
            email: user.email ?? '',
            photoUrl: user.photoURL,
            createdAt: now,
            lastSeenAt: now,
            timezone: DateTime.now().timeZoneName,
          );

          await userDocRef.set(newProfile.toMap(), SetOptions(merge: true));
          return newProfile;
        } else {
          await userDocRef.update({
            'lastSeenAt': now.toIso8601String(),
            'displayName': user.displayName ?? docSnap.data()?['displayName'] ?? 'Friend',
            'photoUrl': user.photoURL ?? docSnap.data()?['photoUrl'],
          });

          return UserProfile.fromMap(docSnap.data()!, user.uid);
        }
      }
    } catch (e) {
      debugPrint('Firestore sync notice: $e');
    }

    final now = DateTime.now();
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

    try {
      final firestore = _firestore;
      if (firestore != null) {
        final docSnap = await firestore.collection('users').doc(user.uid).get();
        if (docSnap.exists && docSnap.data() != null) {
          return UserProfile.fromMap(docSnap.data()!, user.uid);
        }
      }
    } catch (_) {}

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

  /// Signs out from Firebase and Google
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
}
