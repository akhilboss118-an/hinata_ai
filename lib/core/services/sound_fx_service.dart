import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/js_interop/js_interop.dart';

/// Production-grade Superhero Audio FX & Haptic Engine
/// Synthesizes high-fidelity web-shoot, spider-sense, nanotech, and level up sound effects
class SoundFxService {
  static final SoundFxService _instance = SoundFxService._internal();
  factory SoundFxService() => _instance;
  SoundFxService._internal() {
    _loadSettings();
  }

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool('sound_fx_muted') ?? false;
    } catch (_) {}
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_fx_muted', _isMuted);
    } catch (_) {}
  }

  /// Authentic pneumatic web-shoot "THWIP!" sound + haptic feedback
  void playThwip() {
    HapticFeedback.mediumImpact();
    if (_isMuted) return;
    if (kIsWeb) {
      callJsMethod('playHeroSound', ['thwip']);
    }
  }

  /// Vibrating Spider-Sense tingling harmonic buzz + heavy haptic pulse
  void playSpiderSense() {
    HapticFeedback.heavyImpact();
    if (_isMuted) return;
    if (kIsWeb) {
      callJsMethod('playHeroSound', ['spider_sense']);
    }
  }

  /// Nanotech suit equip & holographic power-up sweep
  void playNanotechEquip() {
    HapticFeedback.mediumImpact();
    if (_isMuted) return;
    if (kIsWeb) {
      callJsMethod('playHeroSound', ['nanotech_equip']);
    }
  }

  /// High-tech tactile tap chime for buttons and touch interactions
  void playTapChime() {
    HapticFeedback.lightImpact();
    if (_isMuted) return;
    if (kIsWeb) {
      callJsMethod('playHeroSound', ['tap_chime']);
    }
  }

  /// Aerodynamic swinging whoosh sound
  void playWhoosh() {
    HapticFeedback.lightImpact();
    if (_isMuted) return;
    if (kIsWeb) {
      callJsMethod('playHeroSound', ['whoosh']);
    }
  }

  /// Level up celebration fanfare + vibration
  void playLevelUp() {
    HapticFeedback.heavyImpact();
    if (_isMuted) return;
    if (kIsWeb) {
      callJsMethod('playHeroSound', ['level_up']);
    }
  }
}
