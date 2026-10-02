import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../l10n/app_localizations.dart';

/// Builds the camera view; tests replace it with a fake.
typedef ScannerBuilder = Widget Function(BuildContext context, ValueChanged<String> onScanned);

Widget cameraScanner(BuildContext context, ValueChanged<String> onScanned) => QrScannerView(onScanned: onScanned);

/// Camera QR scanner (mobile_scanner). Only QR codes are decoded.
class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key, required this.onScanned});

  final ValueChanged<String> onScanned;

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  final _controller = MobileScannerController(formats: const [BarcodeFormat.qrCode]);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    // The frame and hint are drawn by the check-in screen's viewfinder.
    return MobileScanner(
      controller: _controller,
      onDetect: (capture) {
        for (final code in capture.barcodes) {
          final value = code.rawValue;
          if (value != null && value.trim().isNotEmpty) {
            widget.onScanned(value);
            return;
          }
        }
      },
      errorBuilder: (context, error) => ColoredBox(
        color: c.nav,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(DcSpace.xxl),
            child: Text(
              l10n.cameraUnavailable,
              textAlign: TextAlign.center,
              style: DcType.ui(16, weight: FontWeight.w600).copyWith(color: DcColors.dark.ink),
            ),
          ),
        ),
      ),
    );
  }
}
