import 'dart:async';
import 'package:flutter/services.dart';

/// Native speech recognition service using Android's SpeechRecognizer
/// This provides continuous speech recognition like Google Live Transcribe
class NativeSpeechRecognitionService {
  static const MethodChannel _methodChannel =
      MethodChannel('com.brainplan.brain_plan/speech');
  static const EventChannel _eventChannel =
      EventChannel('com.brainplan.brain_plan/speech_events');

  Stream<Map<dynamic, dynamic>>? _speechStream;
  StreamSubscription<Map<dynamic, dynamic>>? _subscription;

  /// Callback for speech results
  Function(String text, bool isFinal)? onResult;

  /// Callback for errors
  Function(String error)? onError;

  /// Callback for sound level changes
  Function(double level)? onSoundLevel;

  /// Callback for status changes
  Function(String status)? onStatus;

  /// Start continuous speech recognition
  Future<void> startListening() async {
    print('=== NATIVE SPEECH: Starting native speech recognition ===');

    try {
      // Start listening via method channel
      await _methodChannel.invokeMethod('startListening');

      // Subscribe to speech events
      _speechStream = _eventChannel.receiveBroadcastStream().map((event) {
        if (event is Map) {
          return Map<dynamic, dynamic>.from(event);
        }
        return <dynamic, dynamic>{};
      });

      _subscription = _speechStream?.listen(
        _handleSpeechEvent,
        onError: (error) {
          print('=== NATIVE SPEECH: Stream error: $error ===');
          onError?.call(error.toString());
        },
      );
    } catch (e) {
      print('=== NATIVE SPEECH: Error starting recognition: $e ===');
      onError?.call(e.toString());
    }
  }

  /// Stop speech recognition
  Future<void> stopListening() async {
    print('=== NATIVE SPEECH: Stopping native speech recognition ===');

    try {
      await _subscription?.cancel();
      _subscription = null;
      await _methodChannel.invokeMethod('stopListening');
    } catch (e) {
      print('=== NATIVE SPEECH: Error stopping recognition: $e ===');
    }
  }

  /// Dispose and cleanup
  Future<void> dispose() async {
    print('=== NATIVE SPEECH: Disposing native speech recognition ===');

    try {
      await _subscription?.cancel();
      _subscription = null;
      await _methodChannel.invokeMethod('dispose');
    } catch (e) {
      print('=== NATIVE SPEECH: Error disposing: $e ===');
    }
  }

  void _handleSpeechEvent(Map<dynamic, dynamic> event) {
    final type = event['type'] as String?;

    print('=== NATIVE SPEECH: Event type: $type, data: $event ===');

    switch (type) {
      case 'started':
        onStatus?.call('started');
        break;

      case 'ready':
        onStatus?.call('ready');
        break;

      case 'beginningOfSpeech':
        onStatus?.call('speaking');
        break;

      case 'endOfSpeech':
        onStatus?.call('ended');
        break;

      case 'result':
        final text = event['text'] as String?;
        final isFinal = event['isFinal'] as bool? ?? false;

        if (text != null && text.isNotEmpty) {
          print('=== NATIVE SPEECH: Result - text: "$text", isFinal: $isFinal ===');
          onResult?.call(text, isFinal);
        }
        break;

      case 'soundLevel':
        final level = (event['level'] as num?)?.toDouble() ?? 0.0;
        onSoundLevel?.call(level);
        break;

      case 'error':
        final error = event['error'] as String? ?? 'Unknown error';
        print('=== NATIVE SPEECH: Error - $error ===');
        onError?.call(error);
        break;

      default:
        print('=== NATIVE SPEECH: Unknown event type: $type ===');
    }
  }
}
