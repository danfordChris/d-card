import 'package:dcard_api/api.dart';
import 'package:flutter/foundation.dart';

/// Where the device's push token comes from. The FCM implementation
/// (firebase_messaging) is added when the door app gets sign-in; tests use fakes.
abstract interface class PushTokenSource {
  /// This install's platform, as the API records it.
  DevicePlatform get platform;

  /// Asks for notification permission if needed and returns the current token,
  /// or null when push is unavailable.
  Future<String?> token();

  /// New tokens issued after [token] (FCM rotates them).
  Stream<String> get tokenRefreshes;
}

/// No push (until the door app has Firebase configured).
class NoPushTokenSource implements PushTokenSource {
  const NoPushTokenSource();

  @override
  DevicePlatform get platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? DevicePlatform.ios : DevicePlatform.android;

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();
}
