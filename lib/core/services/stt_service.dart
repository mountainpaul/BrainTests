import 'package:speech_to_text/speech_to_text.dart';

/// Speech-to-Text service for Audio Verbal Learning Test
/// Handles voice recognition with automatic stop detection
class STTService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  String _recognizedText = '';
  DateTime _lastSpeechTime = DateTime.now();

  /// Initialize STT service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => print('STT Error: $error'),
        onStatus: (status) => print('STT Status: $status'),
      );
      return _isInitialized;
    } catch (e) {
      print('Failed to initialize STT: $e');
      return false;
    }
  }

  /// Check if speech recognition is available
  bool get isAvailable => _isInitialized && !_isListening;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Listen for user speech and return list of words
  /// Automatically stops after:
  /// - 3 seconds of silence
  /// - 5 words have been spoken
  /// - Manual stop() call
  Future<List<String>> listenForWords({
    int maxWords = 5,
    Duration silenceTimeout = const Duration(seconds: 3),
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Speech recognition not available');
      }
    }

    _recognizedText = '';
    _lastSpeechTime = DateTime.now();
    _isListening = true;

    // Start listening
    await _speechToText.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        _lastSpeechTime = DateTime.now();

        // Auto-stop if max words reached
        final words = _parseWords(_recognizedText);
        if (words.length >= maxWords) {
          stop();
        }
      },
      listenFor: const Duration(seconds: 30), // Max listening duration
      pauseFor: silenceTimeout,
      partialResults: true,
      localeId: 'en_US',
    );

    // Wait for listening to complete (either by silence or max words)
    while (_isListening && _speechToText.isListening) {
      await Future.delayed(const Duration(milliseconds: 100));

      // Check for silence timeout
      if (DateTime.now().difference(_lastSpeechTime) > silenceTimeout) {
        await stop();
        break;
      }
    }

    // Parse and return words
    return _parseWords(_recognizedText);
  }

  /// Stop listening
  Future<void> stop() async {
    if (_isListening) {
      _isListening = false;
      await _speechToText.stop();
    }
  }

  /// Cancel listening (doesn't save results)
  Future<void> cancel() async {
    if (_isListening) {
      _isListening = false;
      await _speechToText.cancel();
      _recognizedText = '';
    }
  }

  /// Parse recognized text into individual words
  List<String> _parseWords(String text) {
    if (text.isEmpty) return [];

    // Split by whitespace and filter empty strings
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  /// Get the last recognized text
  String get lastRecognizedText => _recognizedText;

  /// Check if speech recognition is available on this device
  Future<bool> isDeviceSupported() async {
    try {
      return await _speechToText.initialize();
    } catch (e) {
      return false;
    }
  }

  /// Get available locales
  Future<List<LocaleName>> getLocales() async {
    try {
      return await _speechToText.locales();
    } catch (e) {
      return [];
    }
  }

  /// Dispose of resources
  void dispose() {
    if (_isListening) {
      _speechToText.stop();
    }
    _isInitialized = false;
    _isListening = false;
  }
}
