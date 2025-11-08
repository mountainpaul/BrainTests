package com.brainplan.app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import io.flutter.plugin.common.EventChannel

class ContinuousSpeechRecognizer(private val context: Context) : RecognitionListener {

    private var speechRecognizer: SpeechRecognizer? = null
    private var isListening = false
    private var eventSink: EventChannel.EventSink? = null
    private val TAG = "ContinuousSpeech"
    private val handler = Handler(Looper.getMainLooper())
    private var timeoutRunnable: Runnable? = null
    private val TIMEOUT_MS = 3000L  // 3 second timeout

    fun setEventSink(sink: EventChannel.EventSink?) {
        this.eventSink = sink
    }

    fun startListening() {
        if (isListening) {
            Log.d(TAG, "Already listening")
            return
        }

        Log.d(TAG, "Starting continuous speech recognition")

        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context)
        speechRecognizer?.setRecognitionListener(this)

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US")
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
            // Force offline recognition
            putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
            // Shorter timeouts for faster word capture
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 1000L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 1000L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, 1500L)
        }

        speechRecognizer?.startListening(intent)
        isListening = true

        // Set timeout to detect hung recognizer
        scheduleTimeout()

        sendEvent(mapOf("type" to "started"))
    }

    fun stopListening() {
        Log.d(TAG, "Stopping speech recognition")
        isListening = false
        speechRecognizer?.stopListening()
    }

    fun destroy() {
        Log.d(TAG, "Destroying speech recognizer")
        isListening = false
        speechRecognizer?.destroy()
        speechRecognizer = null
    }

    private fun sendEvent(event: Map<String, Any>) {
        handler.post {
            eventSink?.success(event)
        }
    }

    override fun onReadyForSpeech(params: Bundle?) {
        Log.d(TAG, "Ready for speech")
        cancelTimeout()  // Cancel timeout when ready
        sendEvent(mapOf("type" to "ready"))
    }

    override fun onBeginningOfSpeech() {
        Log.d(TAG, "Beginning of speech")
        sendEvent(mapOf("type" to "beginningOfSpeech"))
    }

    override fun onRmsChanged(rmsdB: Float) {
        // Only send sound level updates occasionally to avoid flooding
        if (rmsdB > -25) {
            sendEvent(mapOf(
                "type" to "soundLevel",
                "level" to rmsdB.toDouble()
            ))
        }
    }

    override fun onBufferReceived(buffer: ByteArray?) {
        // Not used
    }

    override fun onEndOfSpeech() {
        Log.d(TAG, "End of speech")
        sendEvent(mapOf("type" to "endOfSpeech"))
    }

    override fun onError(error: Int) {
        val errorMessage = when (error) {
            SpeechRecognizer.ERROR_AUDIO -> "audio_error"
            SpeechRecognizer.ERROR_CLIENT -> "client_error"
            SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "permission_error"
            SpeechRecognizer.ERROR_NETWORK -> "network_error"
            SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "network_timeout"
            SpeechRecognizer.ERROR_NO_MATCH -> "no_match"
            SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "recognizer_busy"
            SpeechRecognizer.ERROR_SERVER -> "server_error"
            SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "speech_timeout"
            else -> "unknown_error"
        }

        Log.e(TAG, "Speech recognition error: $errorMessage ($error)")

        sendEvent(mapOf(
            "type" to "error",
            "error" to errorMessage,
            "code" to error
        ))

        // Auto-restart on timeout errors to maintain continuous recognition
        if (isListening && (error == SpeechRecognizer.ERROR_NO_MATCH ||
            error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT)) {
            Log.d(TAG, "Auto-restarting after $errorMessage")
            // Reset flag IMMEDIATELY to prevent race condition
            isListening = false
            handler.postDelayed({
                speechRecognizer?.destroy()
                startListening()
            }, 100)
        }
    }

    override fun onResults(results: Bundle?) {
        val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
        if (matches != null && matches.isNotEmpty()) {
            val text = matches[0]
            Log.d(TAG, "Final result: $text")

            sendEvent(mapOf(
                "type" to "result",
                "text" to text,
                "isFinal" to true
            ))

            // Restart for continuous recognition
            if (isListening) {
                // Reset flag IMMEDIATELY to prevent race condition
                isListening = false
                handler.postDelayed({
                    speechRecognizer?.destroy()
                    startListening()
                }, 100)
            }
        }
    }

    override fun onPartialResults(partialResults: Bundle?) {
        val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
        if (matches != null && matches.isNotEmpty()) {
            val text = matches[0]
            Log.d(TAG, "Partial result: $text")

            sendEvent(mapOf(
                "type" to "result",
                "text" to text,
                "isFinal" to false
            ))
        }
    }

    override fun onEvent(eventType: Int, params: Bundle?) {
        Log.d(TAG, "Event: $eventType")
    }

    private fun scheduleTimeout() {
        cancelTimeout()
        timeoutRunnable = Runnable {
            Log.w(TAG, "Recognition timeout - forcing restart")
            if (isListening) {
                speechRecognizer?.cancel()
                speechRecognizer?.destroy()
                isListening = false
                startListening()
            }
        }
        handler.postDelayed(timeoutRunnable!!, TIMEOUT_MS)
    }

    private fun cancelTimeout() {
        timeoutRunnable?.let { handler.removeCallbacks(it) }
        timeoutRunnable = null
    }
}
