import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'supabase_service.dart';

class SyncManager {
  SyncManager(this._supabaseService);

  final SupabaseService _supabaseService;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = false;

  void initialize() {
    // Initial check
    _checkConnectivity();

    // Listen to changes
    _subscription = Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
    
    // Trigger initial fetch if possible
    // We delay slightly to ensure auth is ready
    Future.delayed(const Duration(seconds: 2), () {
      if (_isOnline) {
        _supabaseService.fetchRemoteData();
        _supabaseService.syncPendingData();
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _handleConnectivityChange(results);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // Check if any result indicates online status
    final isNowOnline = results.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi || 
      result == ConnectivityResult.ethernet);

    if (isNowOnline && !_isOnline) {
      debugPrint('Device is back online. Triggering sync...');
      _supabaseService.syncPendingData();
      _supabaseService.fetchRemoteData();
    }

    _isOnline = isNowOnline;
  }

  void dispose() {
    _subscription?.cancel();
  }
  
  /// Manual trigger for sync (e.g. pull-to-refresh)
  Future<void> syncNow() async {
    if (_isOnline) {
      await _supabaseService.syncPendingData();
      await _supabaseService.fetchRemoteData();
    }
  }
}
