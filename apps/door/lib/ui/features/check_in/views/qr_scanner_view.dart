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
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
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
            color: Colors.black,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.cameraUnavailable,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Text(
            l10n.scanHint,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
