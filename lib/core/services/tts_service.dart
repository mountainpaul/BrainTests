import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service for Audio Verbal Learning Test
/// Provides American English voice with controlled pacing
class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// Initialize TTS with American English voice
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set language to American English
      await _flutterTts.setLanguage("en-US");

      // Set speech rate (0.0 - 1.0, default is ~0.5)
      // 0.5 is normal speaking rate
      await _flutterTts.setSpeechRate(0.5);

      // Set volume (0.0 - 1.0)
      await _flutterTts.setVolume(1.0);

      // Set pitch (0.5 - 2.0, 1.0 is normal)
      await _flutterTts.setPitch(1.0);

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize TTS: $e');
    }
  }

  /// Speak a list of words at 1 word per second
  /// Returns after all words have been spoken
  Future<void> speakWordList(List<String> words) async {
    if (!_isInitialized) {
      await initialize();
    }

    for (int i = 0; i < words.length; i++) {
      await _flutterTts.speak(words[i]);

      // Wait for speech to complete
      await _waitForSpeechToComplete();

      // Wait 2 seconds between words (except after the last word)
      if (i < words.length - 1) {
        await Future.delayed(const Duration(milliseconds: 2000));
      }
    }
  }

  /// Speak a single word
  Future<void> speakWord(String word) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _flutterTts.speak(word);
    await _waitForSpeechToComplete();
  }

  /// Stop current speech
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Wait for current speech to complete
  Future<void> _waitForSpeechToComplete() async {
    // Set up a completion handler
    bool completed = false;

    _flutterTts.setCompletionHandler(() {
      completed = true;
    });

    // Wait for completion (with timeout)
    final timeout = DateTime.now().add(const Duration(seconds: 10));
    while (!completed && DateTime.now().isBefore(timeout)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Reset handler
    _flutterTts.setCompletionHandler(() {});
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await _flutterTts.stop();
    _isInitialized = false;
  }

  /// Check if TTS is available on this device
  Future<bool> isLanguageAvailable() async {
    try {
      final languages = await _flutterTts.getLanguages as List;
      return languages.contains('en-US');
    } catch (e) {
      return false;
    }
  }

  /// Get available voices for en-US
  Future<List<dynamic>> getVoices() async {
    try {
      final voices = await _flutterTts.getVoices as List<dynamic>;
      // Filter for English (United States) voices
      return voices.where((voice) =>
        voice['locale'] != null &&
        voice['locale'].toString().startsWith('en-US')
      ).toList();
    } catch (e) {
      return [];
    }
  }

  /// Set specific voice (optional - allows user to choose voice)
  Future<void> setVoice(Map<String, String> voice) async {
    await _flutterTts.setVoice(voice);
  }
}
