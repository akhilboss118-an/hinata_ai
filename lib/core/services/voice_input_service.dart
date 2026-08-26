import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../utils/js_interop/js_interop.dart';

/// Cross-platform Voice Input Service for Mobile (Android & iOS) and Web browsers
class VoiceInputService {
  static final VoiceInputService _instance = VoiceInputService._internal();
  factory VoiceInputService() => _instance;
  VoiceInputService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  bool get isListening => _isListening;

  /// Checks if Speech Recognition is supported in the current runtime environment
  Future<bool> get isSupported async {
    if (kIsWeb) {
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
    } else {
      if (!_isInitialized) {
        _isInitialized = await _speech.initialize(
          onError: (val) => debugPrint('STT Init Error: ${val.errorMsg}'),
          onStatus: (val) => debugPrint('STT Init Status: $val'),
        );
      }
      return _isInitialized;
    }
  }

  /// Starts listening to microphone speech across Mobile & Web
  Future<bool> startListening({
    required Function(String text) onResult,
    Function(String error)? onError,
    Function(bool isListening)? onStateChanged,
  }) async {
    if (kIsWeb) {
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
        debugPrint('VoiceInputService Web error: $e');
        _isListening = false;
        onStateChanged?.call(false);
        onError?.call(e.toString());
        return false;
      }
    } else {
      // Native Android & iOS Speech-to-Text
      try {
        if (!_isInitialized) {
          _isInitialized = await _speech.initialize(
            onError: (val) {
              debugPrint('Native STT error: ${val.errorMsg}');
              _isListening = false;
              onStateChanged?.call(false);
              onError?.call(val.errorMsg.isNotEmpty ? val.errorMsg : 'Speech recognition error');
            },
            onStatus: (status) {
              debugPrint('Native STT status: $status');
              if (status == 'done' || status == 'notListening') {
                if (_isListening) {
                  _isListening = false;
                  onStateChanged?.call(false);
                }
              }
            },
          );
        }

        if (!_isInitialized) {
          onError?.call('Microphone or Speech Recognition permission was not granted.');
          _isListening = false;
          onStateChanged?.call(false);
          return false;
        }

        String lastRecognized = '';

        final success = await _speech.listen(
          onResult: (result) {
            lastRecognized = result.recognizedWords;
            if (result.finalResult || (result.confidence > 0.7 && lastRecognized.isNotEmpty)) {
              _isListening = false;
              onStateChanged?.call(false);
              _speech.stop();
              onResult(lastRecognized);
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenFor: const Duration(seconds: 25),
            pauseFor: const Duration(seconds: 3),
            partialResults: true,
            cancelOnError: true,
            listenMode: stt.ListenMode.dictation,
          ),
        );

        _isListening = success == true;
        onStateChanged?.call(_isListening);
        return _isListening;
      } catch (e) {
        debugPrint('VoiceInputService Mobile error: $e');
        _isListening = false;
        onStateChanged?.call(false);
        onError?.call('Could not start microphone: $e');
        return false;
      }
    }
  }

  /// Stops current speech recognition
  void stopListening() {
    _isListening = false;
    if (kIsWeb) {
      try {
        callJsMethod('stopHinataSpeech', []);
      } catch (_) {}
    } else {
      try {
        _speech.stop();
      } catch (_) {}
    }
  }
}
