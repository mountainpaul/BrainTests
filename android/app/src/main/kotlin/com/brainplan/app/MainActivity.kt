package com.brainplan.app

import android.Manifest
import android.accounts.AccountManager
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.UserManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity : FlutterActivity() {
    private val SPEECH_CHANNEL = "com.brainplan.brain_plan/speech"
    private val SPEECH_EVENT_CHANNEL = "com.brainplan.brain_plan/speech_events"
    private val USER_INFO_CHANNEL = "com.brainplan.app/user_info"
    private val PERMISSION_REQUEST_CODE = 1001

    private var speechRecognizer: ContinuousSpeechRecognizer? = null
    private var pendingResult: Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method channel for getting user info
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USER_INFO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPrimaryGoogleAccount" -> {
                    val accountManager = getSystemService(ACCOUNT_SERVICE) as AccountManager
                    val accounts = accountManager.getAccountsByType("com.google")
                    if (accounts.isNotEmpty()) {
                        // Return the first Google account (usually the primary one)
                        result.success(accounts[0].name)
                    } else {
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Method channel for starting/stopping recognition
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SPEECH_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    // Check if we have permission
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                            != PackageManager.PERMISSION_GRANTED) {
                            // Request permission
                            pendingResult = result
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.RECORD_AUDIO),
                                PERMISSION_REQUEST_CODE
                            )
                            return@setMethodCallHandler
                        }
                    }

                    // Permission granted, start listening
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

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted, start listening
                if (speechRecognizer == null) {
                    speechRecognizer = ContinuousSpeechRecognizer(this)
                }
                speechRecognizer?.startListening()
                pendingResult?.success(true)
            } else {
                // Permission denied
                pendingResult?.error("PERMISSION_DENIED", "Microphone permission denied", null)
            }
            pendingResult = null
        }
    }

    override fun onDestroy() {
        speechRecognizer?.destroy()
        speechRecognizer = null
        super.onDestroy()
    }
}
