import 'package:connectivity_plus/connectivity_plus.dart';

/// Whether the phone has a network interface (not proof the API is reachable).
abstract interface class ConnectivitySource {
  Future<bool> hasNetwork();

  /// Emits on every change: true when some network is up.
  Stream<bool> get changes;
}

class PlatformConnectivity implements ConnectivitySource {
  PlatformConnectivity([Connectivity? connectivity]) : _c = connectivity ?? Connectivity();

  final Connectivity _c;

  static bool _up(List<ConnectivityResult> r) => r.any((x) => x != ConnectivityResult.none);

  @override
  Future<bool> hasNetwork() async => _up(await _c.checkConnectivity());

  @override
  Stream<bool> get changes => _c.onConnectivityChanged.map(_up);
}

/// For builds and tests without the plugin: always "maybe online", no events.
class NoConnectivitySource implements ConnectivitySource {
  const NoConnectivitySource();

  @override
  Future<bool> hasNetwork() async => true;

  @override
  Stream<bool> get changes => const Stream.empty();
}
