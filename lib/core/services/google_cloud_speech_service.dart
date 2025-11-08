import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:google_speech/google_speech.dart';
import 'package:google_speech/generated/google/cloud/speech/v1/cloud_speech.pb.dart' show StreamingRecognizeResponse;
import 'package:record/record.dart';

/// Service for continuous speech recognition using Google Cloud Speech-to-Text API
/// Provides beep-free streaming recognition for fluency tests
class GoogleCloudSpeechService {
  SpeechToText? _speechToText;
  final _audioRecorder = AudioRecorder();
  StreamSubscription<StreamingRecognizeResponse>? _audioStreamSubscription;
  ServiceAccount? _serviceAccount;

  // Stream controllers for speech events
  final _resultController = StreamController<SpeechRecognitionResult>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  // Public streams
  Stream<SpeechRecognitionResult> get resultStream => _resultController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<String> get statusStream => _statusController.stream;

  bool _isListening = false;
  bool get isListening => _isListening;

  /// Initialize the service by loading credentials from assets
  Future<bool> initialize() async {
    try {
      // Load service account credentials from assets
      final jsonString = await rootBundle.loadString('assets/google_cloud_credentials.json');
      final credentialsJson = json.decode(jsonString);
      _serviceAccount = ServiceAccount.fromString(jsonString);

      // Initialize Speech-to-Text client
      _speechToText = SpeechToText.viaServiceAccount(_serviceAccount!);

      _statusController.add('initialized');
      print('✓ Google Cloud Speech-to-Text initialized successfully');
      return true;
    } catch (e) {
      final error = 'Failed to initialize Google Cloud Speech-to-Text: $e';
      print('✗ $error');
      _errorController.add(error);
      _statusController.add('error');
      return false;
    }
  }

  /// Start continuous streaming recognition
  Future<void> startListening({
    String languageCode = 'en-US',
    bool enableAutomaticPunctuation = false,
    int maxAlternatives = 1,
  }) async {
    if (_isListening) {
      print('Already listening');
      return;
    }

    if (_speechToText == null) {
      final initialized = await initialize();
      if (!initialized) {
        _errorController.add('Failed to initialize service');
        return;
      }
    }

    try {
      _isListening = true;
      _statusController.add('starting');

      // Configure recognition
      final config = RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        model: RecognitionModel.command_and_search, // Good for single words like animal names
        enableAutomaticPunctuation: enableAutomaticPunctuation,
        sampleRateHertz: 16000,
        languageCode: languageCode,
        maxAlternatives: maxAlternatives,
      );

      final streamingConfig = StreamingRecognitionConfig(
        config: config,
        interimResults: true, // Get interim results for real-time feedback
      );

      // Start audio recording
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission not granted');
      }

      // Create audio stream
      final audioStream = await _audioRecorder.startStream(
        RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      // Listen to streaming recognition responses
      final responseStream = _speechToText!.streamingRecognize(
        streamingConfig,
        audioStream,
      );

      _audioStreamSubscription = responseStream.listen(
        (response) {
          if (response.results.isEmpty) return;

          final result = response.results.first;
          if (result.alternatives.isEmpty) return;

          final recognitionResult = SpeechRecognitionResult(
            transcript: result.alternatives.first.transcript,
            isFinal: result.isFinal,
            confidence: result.alternatives.first.confidence,
          );

          _resultController.add(recognitionResult);

          if (result.isFinal) {
            print('Final result: ${recognitionResult.transcript}');
          } else {
            print('Interim result: ${recognitionResult.transcript}');
          }
        },
        onError: (error) {
          print('Streaming error: $error');
          _errorController.add('Streaming error: $error');
        },
        onDone: () {
          print('Streaming completed');
          _statusController.add('completed');
        },
      );

      _statusController.add('listening');
      print('✓ Started listening with Google Cloud Speech-to-Text');
    } catch (e) {
      _isListening = false;
      final error = 'Error starting speech recognition: $e';
      print('✗ $error');
      _errorController.add(error);
      _statusController.add('error');
    }
  }

  /// Stop listening and clean up resources
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      _isListening = false;

      // Stop audio recording
      await _audioRecorder.stop();

      // Cancel audio stream subscription
      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;

      _statusController.add('stopped');
      print('✓ Stopped listening');
    } catch (e) {
      print('Error stopping speech recognition: $e');
      _errorController.add('Error stopping: $e');
    }
  }

  /// Dispose of all resources
  Future<void> dispose() async {
    await stopListening();
    await _resultController.close();
    await _errorController.close();
    await _statusController.close();
    await _audioRecorder.dispose();
    print('✓ Google Cloud Speech Service disposed');
  }

  /// Check if the service is properly configured
  Future<bool> isConfigured() async {
    try {
      await rootBundle.load('assets/google_cloud_credentials.json');
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Result from speech recognition
class SpeechRecognitionResult {
  final String transcript;
  final bool isFinal;
  final double confidence;

  SpeechRecognitionResult({
    required this.transcript,
    required this.isFinal,
    required this.confidence,
  });

  @override
  String toString() {
    return 'SpeechRecognitionResult{transcript: $transcript, isFinal: $isFinal, confidence: $confidence}';
  }
}
