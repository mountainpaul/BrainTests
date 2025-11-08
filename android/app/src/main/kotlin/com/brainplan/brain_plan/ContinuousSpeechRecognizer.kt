package com.brainplan.brain_plan

import android.content.Context
import android.content.Intent
import android.media.AudioManager
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
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private var originalMusicVolume = 0
    private var originalNotificationVolume = 0
    private var originalSystemVolume = 0

    fun setEventSink(sink: EventChannel.EventSink?) {
        this.eventSink = sink
    }

    private fun muteSystemSounds() {
        // Save original volumes
        originalMusicVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
        originalNotificationVolume = audioManager.getStreamVolume(AudioManager.STREAM_NOTIFICATION)
        originalSystemVolume = audioManager.getStreamVolume(AudioManager.STREAM_SYSTEM)

        // Mute system beep sounds
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)
        audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, 0, 0)
        audioManager.setStreamVolume(AudioManager.STREAM_SYSTEM, 0, 0)

        Log.d(TAG, "Muted system sounds - Music: $originalMusicVolume, Notification: $originalNotificationVolume, System: $originalSystemVolume")
    }

    private fun unmuteSystemSounds() {
        // Restore original volumes
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, originalMusicVolume, 0)
        audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, originalNotificationVolume, 0)
        audioManager.setStreamVolume(AudioManager.STREAM_SYSTEM, originalSystemVolume, 0)

        Log.d(TAG, "Restored system sounds - Music: $originalMusicVolume, Notification: $originalNotificationVolume, System: $originalSystemVolume")
    }

    fun startListening() {
        if (isListening) {
            Log.d(TAG, "Already listening")
            return
        }

        Log.d(TAG, "Starting continuous speech recognition")

        // Mute system beep sounds before starting recognition
        muteSystemSounds()

        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context)
        speechRecognizer?.setRecognitionListener(this)

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US")
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
            // Request continuous/dictation mode
            putExtra("android.speech.extra.DICTATION_MODE", true)
            // Set long timeouts to avoid restarts during 60-second test
            // This reduces beeping but means user must keep talking
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 60000L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 60000L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, 60000L)
            // Prefer offline recognition to avoid network delays
            putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
            // Try to disable beep sounds
            putExtra("android.speech.extra.AUDIO_SOURCE", android.media.MediaRecorder.AudioSource.VOICE_RECOGNITION)
            putExtra("android.speech.extras.BEEP_SOUND_VOLUME", 0.0f)
            putExtra("android.speech.extras.AUDIO_PROMPT", false)
        }

        speechRecognizer?.startListening(intent)
        isListening = true

        sendEvent(mapOf("type" to "started"))
    }

    fun stopListening() {
        Log.d(TAG, "Stopping speech recognition")
        isListening = false
        speechRecognizer?.stopListening()

        // Restore system sounds after stopping
        unmuteSystemSounds()
    }

    fun destroy() {
        Log.d(TAG, "Destroying speech recognizer")
        isListening = false
        speechRecognizer?.destroy()
        speechRecognizer = null

        // Restore system sounds when destroying
        unmuteSystemSounds()
    }

    private fun sendEvent(event: Map<String, Any>) {
        handler.post {
            eventSink?.success(event)
        }
    }

    override fun onReadyForSpeech(params: Bundle?) {
        Log.d(TAG, "Ready for speech")
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

        // Only send error events for REAL errors (not timeout/no_match which are expected)
        // This prevents false "microphone disabled" messages
        val isRecoverableError = (error == SpeechRecognizer.ERROR_NO_MATCH ||
                                  error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT)

        if (!isRecoverableError) {
            sendEvent(mapOf(
                "type" to "error",
                "error" to errorMessage,
                "code" to error
            ))
        } else {
            Log.d(TAG, "Recoverable error (auto-restarting): $errorMessage")
        }

        // Auto-restart on timeout/no-match errors to maintain continuous recognition
        if (isListening && isRecoverableError) {
            Log.d(TAG, "Auto-restarting after $errorMessage")
            handler.postDelayed({
                if (isListening) {
                    speechRecognizer?.destroy()
                    startListening()
                }
            }, 50)  // Reduced from 100ms to 50ms for faster restart
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

            // Restart for continuous recognition (fast restart for better continuous capture)
            if (isListening) {
                handler.postDelayed({
                    if (isListening) {
                        speechRecognizer?.destroy()
                        startListening()
                    }
                }, 50)  // Reduced from 100ms to 50ms for faster restart
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
}
