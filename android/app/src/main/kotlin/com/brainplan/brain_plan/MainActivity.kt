package com.brainplan.brain_plan

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SPEECH_CHANNEL = "com.brainplan.brain_plan/speech"
    private val SPEECH_EVENT_CHANNEL = "com.brainplan.brain_plan/speech_events"

    private var speechRecognizer: ContinuousSpeechRecognizer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method channel for starting/stopping recognition
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SPEECH_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    if (speechRecognizer == null) {
                        speechRecognizer = ContinuousSpeechRecognizer(this)
                    }
                    speechRecognizer?.startListening()
                    result.success(true)
                }
                "stopListening" -> {
                    speechRecognizer?.stopListening()
                    result.success(true)
                }
                "dispose" -> {
                    speechRecognizer?.destroy()
                    speechRecognizer = null
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Event channel for streaming speech results
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SPEECH_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    speechRecognizer?.setEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    speechRecognizer?.setEventSink(null)
                }
            }
        )
    }

    override fun onDestroy() {
        speechRecognizer?.destroy()
        speechRecognizer = null
        super.onDestroy()
    }
}
