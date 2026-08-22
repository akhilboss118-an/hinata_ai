/// Application level global constants
abstract class AppConstants {
  static const String appName = 'Hinata AI';
  static const String appTagline = 'Your Persistent 3D AI Companion';
  static const String defaultCharacterName = 'Hinata';
  
  // Storage Keys
  static const String keyUserUid = 'hinata_user_uid';
  static const String keyUserEmail = 'hinata_user_email';
  static const String keyVoiceEnabled = 'hinata_voice_enabled';
  static const String keySelectedVoice = 'hinata_selected_voice';
  
  // Asset Paths
  static const String modelGirlGlb = 'assets/models/girl.glb';
  
  // Default Settings Values
  static const double defaultKindness = 0.9;
  static const double defaultPlayfulness = 0.8;
  static const double defaultShyness = 0.6;
  static const double defaultEnergy = 0.85;
}
