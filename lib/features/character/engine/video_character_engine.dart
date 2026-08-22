import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/character_emotion.dart';
import '../models/character_gesture.dart';
import 'character_state.dart';

/// Video-based Character Stage replacing 3D GLB viewport.
/// Plays seamless looping MP4 video clips tailored to Hinata's current emotional state.
class VideoCharacterEngine extends StatefulWidget {
  final CharacterState state;

  const VideoCharacterEngine({
    super.key,
    required this.state,
  });

  @override
  State<VideoCharacterEngine> createState() => _VideoCharacterEngineState();
}

class _VideoCharacterEngineState extends State<VideoCharacterEngine> {
  VideoPlayerController? _controller;
  String? _currentVideoPath;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadVideoForState(widget.state);
  }

  @override
  void didUpdateWidget(covariant VideoCharacterEngine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentEmotion != widget.state.currentEmotion ||
        oldWidget.state.activeGesture != widget.state.activeGesture) {
      _loadVideoForState(widget.state);
    }
  }

  String _getVideoAssetPath(CharacterState state) {
    final gesture = state.activeGesture;
    if (gesture != null) {
      if (gesture == CharacterGesture.headPat ||
          gesture == CharacterGesture.hold ||
          gesture == CharacterGesture.cheekPoke ||
          gesture == CharacterGesture.noseTap) {
        return 'assets/videos/reaction.mp4';
      } else if (gesture == CharacterGesture.poke) {
        return state.currentEmotion == CharacterEmotion.annoyed
            ? 'assets/videos/angry.mp4'
            : 'assets/videos/reaction.mp4';
      } else if (gesture == CharacterGesture.swipe ||
                 gesture == CharacterGesture.tickle) {
        return 'assets/videos/excited.mp4';
      }
    }

    switch (state.currentEmotion) {
      case CharacterEmotion.angry:
      case CharacterEmotion.annoyed:
        return 'assets/videos/angry.mp4';
      case CharacterEmotion.sad:
      case CharacterEmotion.crying:
      case CharacterEmotion.sleepy:
        return 'assets/videos/sad.mp4';
      case CharacterEmotion.happy:
      case CharacterEmotion.excited:
      case CharacterEmotion.laughing:
      case CharacterEmotion.playful:
      case CharacterEmotion.affectionate:
        return 'assets/videos/excited.mp4';
      case CharacterEmotion.shy:
      case CharacterEmotion.embarrassed:
      case CharacterEmotion.surprised:
        return 'assets/videos/reaction.mp4';
      case CharacterEmotion.neutral:
      case CharacterEmotion.confused:
      case CharacterEmotion.thinking:
        return 'assets/videos/idle.mp4';
    }
  }

  Future<void> _loadVideoForState(CharacterState state) async {
    final videoPath = _getVideoAssetPath(state);
    if (videoPath == _currentVideoPath && _controller != null) return;

    _currentVideoPath = videoPath;
    final oldController = _controller;

    final newController = VideoPlayerController.asset(videoPath);

    try {
      await newController.initialize();
      await newController.setLooping(true);
      await newController.setVolume(0.0); // Muted for browser web autoplay policy
      await newController.play();

      if (mounted) {
        setState(() {
          _controller = newController;
          _isInitialized = true;
        });
        oldController?.dispose();
      } else {
        newController.dispose();
      }
    } catch (e) {
      debugPrint('VideoPlayer initialization error for $videoPath: $e');
      if (mounted) {
        setState(() => _isInitialized = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized && _controller != null && _controller!.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      );
    }

    // Fallback Image view while video initializes or loads
    return Center(
      child: Image.asset(
        'assets/images/hinata_character.png',
        fit: BoxFit.contain,
        height: MediaQuery.of(context).size.height * 0.65,
      ),
    );
  }
}
