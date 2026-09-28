import 'package:dcard_api/api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Where the device's push token comes from (FCM in the app, fakes in tests).
abstract interface class PushTokenSource {
  /// This install's platform, as the API records it.
  DevicePlatform get platform;

  /// Asks for notification permission if needed and returns the current token,
  /// or null when push is unavailable (permission denied, no Play services, no config).
  Future<String?> token();

  /// New tokens issued after [token] (FCM rotates them).
  Stream<String> get tokenRefreshes;
}

/// Firebase Cloud Messaging (docs/design/integrations/firebase.md › FCM/APNs).
class FirebasePushTokenSource implements PushTokenSource {
  FirebasePushTokenSource(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  DevicePlatform get platform => devicePlatform();

  @override
  Future<String?> token() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return null;
    return _messaging.getToken();
  }

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;
}

/// No push (dev fake sign-in, builds without Firebase config).
class NoPushTokenSource implements PushTokenSource {
  const NoPushTokenSource();

  @override
  DevicePlatform get platform => devicePlatform();

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();
}

DevicePlatform devicePlatform() =>
    defaultTargetPlatform == TargetPlatform.iOS ? DevicePlatform.ios : DevicePlatform.android;
