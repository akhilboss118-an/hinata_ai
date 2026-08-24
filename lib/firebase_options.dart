import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for Hinata AI across Web, Android, and Windows
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB1IQdRLXtU5iPSXRJK6aGaU0cmoOlOuSI',
    appId: '1:769390720216:web:017d96366023738e4553ad',
    messagingSenderId: '769390720216',
    projectId: 'hinata-ai-cecd3-b498a',
    authDomain: 'hinata-ai-cecd3-b498a.firebaseapp.com',
    storageBucket: 'hinata-ai-cecd3-b498a.firebasestorage.app',
    measurementId: 'G-VGSZFLMP0B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB1IQdRLXtU5iPSXRJK6aGaU0cmoOlOuSI',
    appId: '1:769390720216:android:017d96366023738e4553ad',
    messagingSenderId: '769390720216',
    projectId: 'hinata-ai-cecd3-b498a',
    storageBucket: 'hinata-ai-cecd3-b498a.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB1IQdRLXtU5iPSXRJK6aGaU0cmoOlOuSI',
    appId: '1:769390720216:windows:017d96366023738e4553ad',
    messagingSenderId: '769390720216',
    projectId: 'hinata-ai-cecd3-b498a',
    storageBucket: 'hinata-ai-cecd3-b498a.firebasestorage.app',
  );
}
