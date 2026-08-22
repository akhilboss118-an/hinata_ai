import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for ideal companion experience
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (_) {}

  // Set system UI navigation style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF06040C),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // NOTE: Firebase initialization skipped — using placeholder keys.
  // Will be re-enabled once real Firebase project credentials are provided.
  // Chat works via Gemini API directly; storage is in-memory for now.

  runApp(
    const ProviderScope(
      child: HinataApp(),
    ),
  );
}
