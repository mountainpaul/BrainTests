# Google Cloud Speech-to-Text Setup Guide

This guide explains how to set up Google Cloud Speech-to-Text API for continuous speech recognition in the Animal Fluency test without beeping.

## Prerequisites
- Google Cloud account
- Billing enabled on your Google Cloud project

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "NEW PROJECT"
3. Enter project name (e.g., "brain-plan-speech")
4. Click "CREATE"

## Step 2: Enable Speech-to-Text API

1. Go to [APIs & Services](https://console.cloud.google.com/apis/library)
2. Search for "Cloud Speech-to-Text API"
3. Click on it and press "ENABLE"

## Step 3: Create Service Account

1. Go to [IAM & Admin → Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts)
2. Click "CREATE SERVICE ACCOUNT"
3. Enter:
   - **Name**: brain-plan-speech-service
   - **Description**: Service account for speech recognition
4. Click "CREATE AND CONTINUE"
5. Grant role: **Cloud Speech Client** or **Cloud Speech Administrator**
6. Click "CONTINUE" → "DONE"

## Step 4: Create and Download JSON Key

1. Click on the service account you just created
2. Go to "KEYS" tab
3. Click "ADD KEY" → "Create new key"
4. Select "JSON" format
5. Click "CREATE"
6. Save the downloaded JSON file securely

**⚠️ IMPORTANT**: Never commit this JSON file to version control!

## Step 5: Add JSON Key to Your Flutter App

### Option A: Store in assets (for development/testing)
1. Create `assets/` directory in your Flutter project root if it doesn't exist
2. Copy the JSON file to `assets/google_cloud_credentials.json`
3. Add to `.gitignore`:
   ```
   # Google Cloud credentials
   assets/google_cloud_credentials.json
   ```
4. Add to `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/google_cloud_credentials.json
   ```

### Option B: Store as environment variable (for production)
For production apps, use Firebase Remote Config or a secure backend to provide credentials.

## Step 6: Load Credentials in App

The credentials will be loaded by the `GoogleCloudSpeechService` automatically from the assets.

## Usage Costs

Google Cloud Speech-to-Text API pricing (as of 2025):
- **First 60 minutes per month**: FREE
- **After 60 minutes**: $0.006 per 15 seconds (about $1.44 per hour)

For a 60-second test:
- **Cost per test**: ~$0.024 (2.4 cents)
- **100 tests per month**: ~$2.40

The free tier covers approximately 60 one-minute tests per month.

## Testing Your Setup

After completing setup:
1. Run `flutter pub get`
2. Restart your app
3. Go to Animal Fluency test
4. The app should use Google Cloud Speech-to-Text for continuous recognition without beeping

## Troubleshooting

### Error: "Permission denied" or "Unauthorized"
- Verify the service account has the "Cloud Speech Client" role
- Check that the JSON key file is valid and not expired
- Ensure Speech-to-Text API is enabled for your project

### Error: "Quota exceeded"
- Check your Google Cloud Console quotas
- Verify billing is enabled
- Check your monthly usage hasn't exceeded free tier

### Audio not being recognized
- Verify microphone permissions are granted
- Check internet connectivity (required for cloud API)
- Review logs for error messages

## Security Best Practices

1. **Never commit credentials to git**
   - Add `assets/google_cloud_credentials.json` to `.gitignore`
   - Use environment variables or secure backends in production

2. **Restrict API key permissions**
   - Only enable Speech-to-Text API
   - Use application restrictions if deploying to production

3. **Monitor usage**
   - Set up billing alerts in Google Cloud Console
   - Monitor API usage regularly

## Next Steps

After setup is complete, the app will automatically use Google Cloud Speech-to-Text for:
- **Continuous streaming recognition** for 60 seconds
- **No beeping sounds** (unlike Android SpeechRecognizer)
- **Better accuracy** with interim and final results
- **No restart delays** during recognition
