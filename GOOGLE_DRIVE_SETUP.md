# Google Drive Backup Setup Guide

## Overview
This guide walks you through setting up Google Drive backup for the Brain Plan app.

## Your App Information
- **Package Name**: `com.brainplan.app`
- **SHA-1 Fingerprint**: `51:BA:E4:35:57:D5:69:4C:43:DD:54:DB:E0:EA:EE:74:E1:28:F9:40`

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Enter project name: `brain-plan` (or your preferred name)
4. Click "Create"

## Step 2: Enable Google Drive API

1. In your project, go to "APIs & Services" → "Library"
2. Search for "Google Drive API"
3. Click on it and press "Enable"

## Step 3: Configure OAuth Consent Screen

1. Go to "APIs & Services" → "OAuth consent screen"
2. Select "External" (or "Internal" if you have a Google Workspace)
3. Click "Create"

### Fill in the form:
- **App name**: Brain Plan
- **User support email**: Your email
- **App logo**: (optional)
- **Application home page**: (optional)
- **Authorized domains**: (leave empty for now)
- **Developer contact information**: Your email

4. Click "Save and Continue"
5. **Scopes**: Click "Add or Remove Scopes"
   - Add: `https://www.googleapis.com/auth/drive.file`
   - Add: `https://www.googleapis.com/auth/drive.appdata`
6. Click "Save and Continue"
7. **Test users**: Add your Gmail account for testing
8. Click "Save and Continue"
9. Review and click "Back to Dashboard"

## Step 4: Create OAuth 2.0 Credentials

1. Go to "APIs & Services" → "Credentials"
2. Click "+ CREATE CREDENTIALS" → "OAuth client ID"
3. Select **Application type**: "Android"

### Fill in the Android OAuth client form:
- **Name**: `Brain Plan Android`
- **Package name**: `com.brainplan.app`
- **SHA-1 certificate fingerprint**: `51:BA:E4:35:57:D5:69:4C:43:DD:54:DB:E0:EA:EE:74:E1:28:F9:40`

4. Click "Create"

## Step 5: Note Your Client ID

After creation, you'll see a dialog with your OAuth 2.0 client ID. It will look like:
```
123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com
```

**IMPORTANT**: Copy this Client ID - you'll need it in the next step!

## Step 6: Update Android Configuration

**IMPORTANT**: Copy the OAuth Client ID you received in Step 5 and add it to the app code:

1. Open `lib/core/services/google_drive_backup_service.dart`
2. Find the line with `_serverClientId`
3. Replace the existing value with your OAuth Client ID

```dart
static const String _serverClientId = 'YOUR-CLIENT-ID-HERE.apps.googleusercontent.com';
```

Your Client ID should look like: `565609588193-qiaik6bsi80kec3j7mnjk1jr18tj8774.apps.googleusercontent.com`

## Step 7: Known Issue - Drive Scope Authorization

**CURRENT STATUS**: Google Sign-In works, but Drive scope authorization is not yet functional.

The app successfully authenticates with Google, but the Drive API scopes (`drive.file` and `drive.appdata`) are not being granted. This is a known issue with google_sign_in 7.x where `authorizationForScopes()` does not automatically show a consent dialog.

**Error in logs**: `[RequestTokenManager] getToken() -> NEED_REMOTE_CONSENT`

**Next Steps to Fix**:
1. Research google_sign_in 7.x proper way to request additional scopes
2. May need to use `GoogleSignIn.instance.requestScopes()` or similar API
3. Alternative: Downgrade to google_sign_in 6.x which had simpler scope handling

## Step 8: Test the Integration (Once Fixed)

1. Build and run the app on your device
2. Go to Settings
3. Tap "Google Drive Backup" → "Sign in"
4. You should see the Google Sign-In screen
5. Sign in with your Google account
6. Grant permissions for Drive access
7. The backup will automatically upload to Google Drive

## Troubleshooting

### "Sign-in cancelled" error
- Verify the SHA-1 fingerprint matches exactly
- Verify the package name is `com.brainplan.app`
- Make sure you added your test Google account in OAuth consent screen
- Wait 5-10 minutes after creating credentials (Google's systems need time to propagate)

### "API not enabled" error
- Go back to Step 2 and ensure Google Drive API is enabled

### "Access denied" error
- Check that you added the correct Drive API scopes in OAuth consent screen
- Verify your Google account is added as a test user

## Where Backups Are Stored

Backups are stored in your Google Drive's **Application Data folder**, which:
- Is private to the app (users can't see it in their Drive)
- Persists across app reinstalls
- Doesn't count against Drive storage quota (currently)
- Is automatically deleted if the user uninstalls the app and clears data

## Production Deployment

Before publishing to Play Store:

1. **Generate Release SHA-1**:
   ```bash
   keytool -list -v -keystore your-release-key.keystore -alias your-alias
   ```

2. **Add Release OAuth Client**:
   - Go back to Google Cloud Console → Credentials
   - Create another OAuth client ID for Android
   - Use the same package name but the **release** SHA-1 fingerprint

3. **Verify OAuth Consent Screen**:
   - Submit for verification if you want to remove "unverified app" warning
   - Or keep in testing mode (limited to 100 test users)

## Support

For issues, check:
- [Google Sign-In Flutter Plugin](https://pub.dev/packages/google_sign_in)
- [Google Drive API Documentation](https://developers.google.com/drive/api/guides/about-sdk)
- [OAuth 2.0 for Mobile Apps](https://developers.google.com/identity/protocols/oauth2/native-app)
