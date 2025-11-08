# Google Cloud Speech-to-Text Integration - Implementation Summary

## What Has Been Done

### 1. ✅ Added Dependencies
Added to `pubspec.yaml`:
- `google_speech: ^5.3.0` - Google Cloud Speech-to-Text API with streaming support
- `record: ^5.1.2` - Audio recording for streaming audio to Google Cloud

Dependencies have been installed with `flutter pub get`.

### 2. ✅ Created Service Class
Created `/lib/core/services/google_cloud_speech_service.dart`:
- Streaming recognition service using Google Cloud Speech-to-Text API
- Supports continuous 60-second recognition without beeping
- Provides streams for results, errors, and status updates
- Uses same callback pattern as the existing native service for easy integration

### 3. ✅ Created Setup Documentation
Created `GOOGLE_CLOUD_SETUP.md` with detailed instructions for:
- Creating Google Cloud project
- Enabling Speech-to-Text API
- Creating service account with credentials
- Adding JSON key to the app
- Cost analysis (free tier covers ~60 one-minute tests/month)

## What Needs To Be Done

### STEP 1: Set Up Google Cloud Credentials

You need to create a Google Cloud project and get API credentials. Follow these steps:

1. **Create Google Cloud Project**:
   - Go to https://console.cloud.google.com/
   - Create new project named "brain-plan-speech"
   - Enable billing (required even for free tier)

2. **Enable Speech-to-Text API**:
   - Go to https://console.cloud.google.com/apis/library
   - Search for "Cloud Speech-to-Text API"
   - Click ENABLE

3. **Create Service Account**:
   - Go to https://console.cloud.google.com/iam-admin/serviceaccounts
   - Click "CREATE SERVICE ACCOUNT"
   - Name: `brain-plan-speech-service`
   - Grant role: **Cloud Speech Client**
   - Create and download JSON key

4. **Add JSON Key to Project**:
   ```bash
   # Create assets directory if it doesn't exist
   mkdir -p assets

   # Copy your downloaded JSON key
   cp ~/Downloads/brain-plan-speech-*.json assets/google_cloud_credentials.json

   # Add to .gitignore to prevent committing credentials
   echo "assets/google_cloud_credentials.json" >> .gitignore
   ```

5. **Update pubspec.yaml** to include the asset:
   ```yaml
   flutter:
     uses-material-design: true
     assets:
       - assets/google_cloud_credentials.json
   ```

### STEP 2: Modify Fluency Test Screen

Now you need to integrate the Google Cloud service into the fluency test screen. The native service is currently used at line 18 of `fluency_test_screen.dart`:

```dart
final _nativeSpeech = NativeSpeechRecognitionService();
```

**Option A: Replace Native Service (Recommended)**

Replace the native service with the Google Cloud service:

```dart
// OLD:
import '../../core/services/native_speech_recognition_service.dart';
final _nativeSpeech = NativeSpeechRecognitionService();

// NEW:
import '../../core/services/google_cloud_speech_service.dart';
final _cloudSpeech = GoogleCloudSpeechService();
```

Then update all references to `_nativeSpeech` to use `_cloudSpeech` instead.

**Option B: Add Fallback Logic**

Keep both services and try Google Cloud first, falling back to native if credentials aren't configured:

```dart
import '../../core/services/google_cloud_speech_service.dart';
import '../../core/services/native_speech_recognition_service.dart';

// In state class:
GoogleCloudSpeechService? _cloudSpeech;
final _nativeSpeech = NativeSpeechRecognitionService();
bool _useCloudSpeech = false;

// In initState:
@override
void initState() {
  super.initState();
  _initializeSpeechService();
}

Future<void> _initializeSpeechService() async {
  _cloudSpeech = GoogleCloudSpeechService();
  final isConfigured = await _cloudSpeech!.isConfigured();

  if (isConfigured) {
    _useCloudSpeech = true;
    print('✓ Using Google Cloud Speech (no beeping!)');
  } else {
    print('⚠️  Using native speech (will beep) - configure Google Cloud for beep-free experience');
  }
}
```

### STEP 3: Update Speech Recognition Callbacks

The Google Cloud service uses streams instead of callbacks. Update the code where callbacks are set:

**OLD (Native Service)**:
```dart
_nativeSpeech.onResult = (String text, bool isFinal) {
  // Handle result
};

_nativeSpeech.onError = (String error) {
  // Handle error
};

_nativeSpeech.onStatus = (String status) {
  // Handle status
};

await _nativeSpeech.startListening();
```

**NEW (Google Cloud Service)**:
```dart
// Subscribe to streams
_cloudSpeech.resultStream.listen((result) {
  // Handle result - result.transcript, result.isFinal, result.confidence
  _handleSpeechResult(result.transcript, result.isFinal);
});

_cloudSpeech.errorStream.listen((error) {
  // Handle error
  print('Speech error: $error');
});

_cloudSpeech.statusStream.listen((status) {
  // Handle status
  print('Speech status: $status');
});

await _cloudSpeech.startListening();
```

### STEP 4: Update Disposal

Make sure to dispose of the service properly:

```dart
@override
void dispose() {
  _cloudSpeech?.dispose();
  _nativeSpeech.dispose();
  _timer?.cancel();
  _textController.dispose();
  super.dispose();
}
```

### STEP 5: Add Microphone Permission (if not already present)

The `record` package requires microphone permissions. Ensure `AndroidManifest.xml` has:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### STEP 6: Test the Implementation

1. **Run flutter pub get** (already done)
2. **Add your Google Cloud credentials** to `assets/google_cloud_credentials.json`
3. **Update pubspec.yaml** to include the asset
4. **Rebuild the app** (hot reload won't work for assets):
   ```bash
   flutter clean
   flutter build apk --debug
   flutter install -d 48241FDAS003ZP
   ```
5. **Test the Animal Fluency test** - should have no beeping!

## Benefits of This Implementation

✅ **No beeping** - Google Cloud Speech-to-Text doesn't use start/stop beeps
✅ **True continuous recognition** - Streams audio continuously for 60 seconds
✅ **Better accuracy** - Google's cloud model is more accurate than on-device
✅ **Interim results** - Get real-time transcription as the user speaks
✅ **Easy to configure** - Simple JSON credential file
✅ **Free tier** - First 60 minutes per month are free (~60 one-minute tests)

## Cost Analysis

- **Free tier**: 60 minutes/month free
- **Beyond free tier**: ~$0.024 per 60-second test (2.4 cents)
- **100 tests/month**: ~$2.40 total cost (first 60 tests free)

## Troubleshooting

### "Failed to initialize Google Cloud Speech-to-Text"
- Verify `assets/google_cloud_credentials.json` exists
- Check that pubspec.yaml includes the asset
- Rebuild app (assets require full rebuild)

### "Permission denied" or "Unauthorized"
- Verify service account has "Cloud Speech Client" role
- Check Speech-to-Text API is enabled in Google Cloud Console
- Verify JSON key is valid (not expired)

### Audio not recognized
- Check microphone permissions
- Verify internet connectivity (required for cloud API)
- Review logs for specific error messages

## Next Steps

1. Complete STEP 1 (Google Cloud setup) - takes about 10 minutes
2. Complete STEP 2 (modify fluency test screen)
3. Complete STEP 3 (update callbacks to use streams)
4. Test and verify beep-free operation!

Refer to `GOOGLE_CLOUD_SETUP.md` for detailed Google Cloud configuration instructions.
