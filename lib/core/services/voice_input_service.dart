import 'package:flutter/foundation.dart';
import '../utils/js_interop/js_interop.dart';

/// Cross-platform Voice Input Service for Mobile & Web browsers
/// Utilizes Web Speech Recognition API with mobile Safari & Chrome compatibility
class VoiceInputService {
  static final VoiceInputService _instance = VoiceInputService._internal();
  factory VoiceInputService() => _instance;
  VoiceInputService._internal();

  bool _isListening = false;
  bool get isListening => _isListening;

  /// Checks if Speech Recognition is supported in the current runtime environment
  bool get isSupported {
    if (!kIsWeb) return false;
    try {
      if (jsContext.hasProperty('hinataSpeech')) {
        final hinataSpeech = jsContext['hinataSpeech'];
        return hinataSpeech.callMethod('hasSupport', []) == true;
      }
      return jsContext.hasProperty('SpeechRecognition') ||
          jsContext.hasProperty('webkitSpeechRecognition');
    } catch (_) {
      return false;
    }
  }

  /// Starts listening to microphone speech
  Future<bool> startListening({
    required Function(String text) onResult,
    Function(String error)? onError,
    Function(bool isListening)? onStateChanged,
  }) async {
    if (!kIsWeb) {
      onError?.call('Voice input is currently supported on Web & Mobile browsers.');
      return false;
    }

    try {
      // Direct call to global helper in web/index.html
      final success = jsContext.callMethod('startHinataSpeech', [
        (String text) {
          _isListening = false;
          onStateChanged?.call(false);
          onResult(text);
        },
        (String error) {
          _isListening = false;
          onStateChanged?.call(false);
          onError?.call(error);
        },
        (bool listening) {
          _isListening = listening;
          onStateChanged?.call(listening);
        },
      ]);

      _isListening = success == true;
      onStateChanged?.call(_isListening);
      return _isListening;
    } catch (e) {
      debugPrint('VoiceInputService error: $e');
      _isListening = false;
      onStateChanged?.call(false);
      onError?.call(e.toString());
      return false;
    }
  }

  /// Stops current speech recognition
  void stopListening() {
    _isListening = false;
    if (kIsWeb) {
      try {
        callJsMethod('stopHinataSpeech', []);
      } catch (_) {}
    }
  }
}
