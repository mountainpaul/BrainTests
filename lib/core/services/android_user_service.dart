import 'package:flutter/services.dart';

/// Service to get the current Android user information
/// This helps identify which Google account to use when multiple accounts exist
class AndroidUserService {
  static const MethodChannel _channel = MethodChannel('com.brainplan.app/user_info');

  /// Get the current Android user's name/email
  /// Returns null if unable to determine
  static Future<String?> getCurrentUserEmail() async {
    try {
      final String? email = await _channel.invokeMethod('getCurrentUserEmail');
      return email;
    } catch (e) {
      print('Error getting current Android user email: $e');
      return null;
    }
  }

  /// Get the primary Google account on the device
  /// Returns null if no account found
  static Future<String?> getPrimaryGoogleAccount() async {
    try {
      final String? email = await _channel.invokeMethod('getPrimaryGoogleAccount');
      return email;
    } catch (e) {
      print('Error getting primary Google account: $e');
      return null;
    }
  }
}
