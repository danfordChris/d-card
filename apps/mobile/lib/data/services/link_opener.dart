import 'package:url_launcher/url_launcher.dart';

/// Opens web pages outside the app (e.g. the hosted payment page). Fakes in tests.
abstract interface class LinkOpener {
  /// Returns false when no app could open [url].
  Future<bool> open(Uri url);
}

class ExternalLinkOpener implements LinkOpener {
  const ExternalLinkOpener();

  @override
  Future<bool> open(Uri url) async {
    // SEC-08: only web links; a host-entered map link must not open other schemes.
    if (url.scheme != 'https' && url.scheme != 'http') return false;
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
