import 'dart:async';

import 'package:dcard_api/api.dart';
import 'package:flutter/foundation.dart';

import '../services/push_token_source.dart';

/// Registers this install's push token with the API for the signed-in user
/// (`POST /api/v1/me/devices`) and removes it on sign-out (`DELETE /api/v1/me/devices/{token}`).
///
/// Push is best-effort: failures are logged and never block sign-in or sign-out.
/// Wired into the door sign-in flow when that exists (walk-in alerts, phase 04).
class PushRegistrationRepository {
  PushRegistrationRepository({required this._api, required this._source, this.app = DeviceApp.door});

  final DefaultApi _api;
  final PushTokenSource _source;
  final DeviceApp app;

  StreamSubscription<String>? _refreshes;
  String? _registered;

  /// The token last registered with the API (null when none).
  String? get registeredToken => _registered;

  /// Call after sign-in (and at start-up when already signed in).
  Future<void> register() async {
    try {
      final token = await _source.token();
      if (token == null || token.isEmpty) return;
      await _send(token);
    } catch (e) {
      debugPrint('Push registration failed: $e');
    }
    _refreshes ??= _source.tokenRefreshes.listen((token) async {
      try {
        await _send(token);
      } catch (e) {
        debugPrint('Push token refresh failed: $e');
      }
    });
  }

  /// Call before signing out, while the ID token is still valid.
  Future<void> unregister() async {
    // Not awaited: a subscription's cancel future may resolve late, and sign-out must not wait on it.
    unawaited(_refreshes?.cancel());
    _refreshes = null;
    final token = _registered;
    _registered = null;
    if (token == null) return;
    try {
      await _api.unregisterDevice(Uri.encodeComponent(token));
    } catch (e) {
      debugPrint('Push unregistration failed: $e');
    }
  }

  Future<void> _send(String token) async {
    await _api.registerDevice(
      deviceRegisterInput: DeviceRegisterInput(token: token, platform: _source.platform, app: app),
    );
    _registered = token;
  }
}
