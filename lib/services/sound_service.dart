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
      print('Initializing SoundService...');
      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: []),
      );
      print('SoundService initialized successfully');
    } catch (e) {
      print('Sound init error: $e');
    }
  }

  Future<void> playMoveSound() async {
    if (!_soundEnabled) {
      print('Sound disabled, not playing move sound');
      return;
    }
    
    try {
      print('Playing move sound...');
      final source = AudioSource.uri(Uri.parse('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'));
      await _audioPlayer.setAudioSource(source, initialPosition: Duration.zero);
      await _audioPlayer.play();
      print('Move sound played successfully');
    } catch (e) {
      print('Error playing move sound: $e');
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
      _playLocalBeep();
    }
  }

  Future<void> playDrawSound() async {
    if (!_soundEnabled) return;
    
    try {
      final source = AudioSource.uri(Uri.parse('https://assets.mixkit.co/active_storage/sfx/2868/2868-preview.mp3'));
      await _audioPlayer.setAudioSource(source, initialPosition: Duration.zero);
      await _audioPlayer.play();
    } catch (e) {
      _playLocalBeep();
    }
  }

  void _playLocalBeep() {
    
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    print('Sound toggled: $_soundEnabled');
  }

  bool get soundEnabled => _soundEnabled;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
