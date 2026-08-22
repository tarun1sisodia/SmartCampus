import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../app/dependency_injection.dart';
import '../bloc/qr_scanner_bloc.dart';
import '../bloc/qr_scanner_event.dart';
import '../bloc/qr_scanner_state.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        final data = barcode.rawValue!;
        // Expected format: sessionId:token
        final parts = data.split(':');
        if (parts.length == 2) {
          final sessionId = parts[0];
          final token = parts[1];

          setState(() => _isProcessing = true);
          context.read<QrScannerBloc>().add(
                QrCodeScanned(sessionId: sessionId, token: token),
              );
        }
      }
    }
  }

  void _showResultDialog(bool success, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(success ? 'Success' : 'Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (success) {
                  Navigator.of(context).pop(); // Go back to dashboard if success
                } else {
                  setState(() => _isProcessing = false);
                  controller.start(); // Resume scanning
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<QrScannerBloc>(),
      child: BlocListener<QrScannerBloc, QrScannerState>(
        listener: (context, state) {
          if (state is QrScannerLoading) {
            controller.stop();
          } else if (state is QrScannerSuccess) {
            _showResultDialog(true, 'Your attendance has been marked successfully.');
          } else if (state is QrScannerFailure) {
            _showResultDialog(false, state.message);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Scan Attendance QR'),
            centerTitle: true,
          ),
          body: Builder(
            builder: (innerContext) {
              return Stack(
                children: [
                  MobileScanner(
                    controller: controller,
                    onDetect: _onDetect,
                  ),
                  // Scanner Overlay
                  Container(
                    decoration: ShapeDecoration(
                      shape: QrScannerOverlayShape(
                        borderColor: Colors.blue,
                        borderRadius: 10,
                        borderLength: 30,
                        borderWidth: 10,
                        cutOutSize: 300,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: BlocBuilder<QrScannerBloc, QrScannerState>(
                      builder: (context, state) {
                        if (state is QrScannerLoading) {
                          return Column(
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Verifying attendance...',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              )
                            ],
                          );
                        }
                        return const Center(
                          child: Text(
                            'Align QR code within the frame',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.blue,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.7),
    this.borderRadius = 10.0,
    this.borderLength = 40.0,
    this.cutOutSize = 300.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(
        rect.right,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.top,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final borderWidthSize = width / 2;
    final borderHeightSize = height / 2;
    final borderSize = cutOutSize / 2;

    var paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas
      ..drawRect(
        Rect.fromLTRB(
            rect.left, rect.top, rect.right, borderHeightSize - borderSize),
        paint,
      )
      ..drawRect(
        Rect.fromLTRB(rect.left, borderHeightSize + borderSize, rect.right,
            rect.bottom),
        paint,
      )
      ..drawRect(
        Rect.fromLTRB(rect.left, borderHeightSize - borderSize,
            borderWidthSize - borderSize, borderHeightSize + borderSize),
        paint,
      )
      ..drawRect(
        Rect.fromLTRB(borderWidthSize + borderSize, borderHeightSize - borderSize,
            rect.right, borderHeightSize + borderSize),
        paint,
      );

    paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawPath(
        Path()
          ..moveTo(borderWidthSize - borderSize, borderHeightSize - borderSize + borderLength)
          ..lineTo(borderWidthSize - borderSize, borderHeightSize - borderSize + borderRadius)
          ..quadraticBezierTo(
              borderWidthSize - borderSize,
              borderHeightSize - borderSize,
              borderWidthSize - borderSize + borderRadius,
              borderHeightSize - borderSize)
          ..lineTo(borderWidthSize - borderSize + borderLength, borderHeightSize - borderSize),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(borderWidthSize + borderSize, borderHeightSize - borderSize + borderLength)
          ..lineTo(borderWidthSize + borderSize, borderHeightSize - borderSize + borderRadius)
          ..quadraticBezierTo(
              borderWidthSize + borderSize,
              borderHeightSize - borderSize,
              borderWidthSize + borderSize - borderRadius,
              borderHeightSize - borderSize)
          ..lineTo(borderWidthSize + borderSize - borderLength, borderHeightSize - borderSize),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(borderWidthSize - borderSize, borderHeightSize + borderSize - borderLength)
          ..lineTo(borderWidthSize - borderSize, borderHeightSize + borderSize - borderRadius)
          ..quadraticBezierTo(
              borderWidthSize - borderSize,
              borderHeightSize + borderSize,
              borderWidthSize - borderSize + borderRadius,
              borderHeightSize + borderSize)
          ..lineTo(borderWidthSize - borderSize + borderLength, borderHeightSize + borderSize),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(borderWidthSize + borderSize, borderHeightSize + borderSize - borderLength)
          ..lineTo(borderWidthSize + borderSize, borderHeightSize + borderSize - borderRadius)
          ..quadraticBezierTo(
              borderWidthSize + borderSize,
              borderHeightSize + borderSize,
              borderWidthSize + borderSize - borderRadius,
              borderHeightSize + borderSize)
          ..lineTo(borderWidthSize + borderSize - borderLength, borderHeightSize + borderSize),
        paint,
      );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
