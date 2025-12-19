import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  
  late AudioPlayer _audioPlayer;
  bool _soundEnabled = true;

  SoundService._internal() {
    _audioPlayer = AudioPlayer();
  }

  factory SoundService() {
    return _instance;
  }

  Future<void> initialize() async {
    try {
      // Set audio session configuration
      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: []),
      );
    } catch (e) {
      debugPrint('Error initializing SoundService: $e');
    }
  }

  Future<void> playMoveSound() async {
    if (!_soundEnabled) return;
    
    try {
      // Play a simple beep sound using just_audio's built-in capabilities
      final source = AudioSource.uri(Uri.parse('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'));
      await _audioPlayer.setAudioSource(source, initialPosition: Duration.zero);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing move sound: $e');
      // Fallback: play a local beep if internet fails
      _playLocalBeep();
    }
  }

  Future<void> playWinSound() async {
    if (!_soundEnabled) return;
    
    try {
      final source = AudioSource.uri(Uri.parse('https://assets.mixkit.co/active_storage/sfx/2867/2867-preview.mp3'));
      await _audioPlayer.setAudioSource(source, initialPosition: Duration.zero);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing win sound: $e');
    }
  }

  Future<void> playDrawSound() async {
    if (!_soundEnabled) return;
    
    try {
      final source = AudioSource.uri(Uri.parse('https://assets.mixkit.co/active_storage/sfx/2868/2868-preview.mp3'));
      await _audioPlayer.setAudioSource(source, initialPosition: Duration.zero);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing draw sound: $e');
    }
  }

  void _playLocalBeep() {
    // Fallback method - can be extended later
    debugPrint('Playing local beep fallback');
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  bool get soundEnabled => _soundEnabled;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
