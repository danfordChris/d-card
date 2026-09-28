import 'package:firebase_messaging/firebase_messaging.dart';

/// Incoming push messages' data payloads (FCM in the app, fakes in tests).
abstract interface class PushMessageSource {
  /// Messages received while the app is in the foreground.
  Stream<Map<String, Object?>> get foreground;

  /// Notifications the user tapped while the app was in the background.
  Stream<Map<String, Object?>> get opened;

  /// The notification that launched the app from terminated state, if any.
  Future<Map<String, Object?>?> initial();
}

/// Firebase Cloud Messaging (docs/design/integrations/firebase.md › FCM/APNs).
class FirebasePushMessageSource implements PushMessageSource {
  FirebasePushMessageSource(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  Stream<Map<String, Object?>> get foreground => FirebaseMessaging.onMessage.map((m) => m.data);

  @override
  Stream<Map<String, Object?>> get opened => FirebaseMessaging.onMessageOpenedApp.map((m) => m.data);

  @override
  Future<Map<String, Object?>?> initial() async => (await _messaging.getInitialMessage())?.data;
}

/// No push (dev fake sign-in, builds without Firebase config).
class NoPushMessageSource implements PushMessageSource {
  const NoPushMessageSource();

  @override
  Stream<Map<String, Object?>> get foreground => const Stream.empty();

  @override
  Stream<Map<String, Object?>> get opened => const Stream.empty();

  @override
  Future<Map<String, Object?>?> initial() async => null;
}
