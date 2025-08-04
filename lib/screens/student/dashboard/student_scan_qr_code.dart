import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class StudentScanQrScreen extends StatefulWidget {
  const StudentScanQrScreen({super.key});

  @override
  State<StudentScanQrScreen> createState() => _StudentScanQrScreenState();
}

class _StudentScanQrScreenState extends State<StudentScanQrScreen> {
  @override
  Widget build(BuildContext context) {
    const scanBoxSize = 250.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              final String? value = barcode.rawValue;

              if (value != null) {
                final classId = extractClassId(value);
                Get.back(result: classId); // send scanned result back
              }
            },
          ),

          // Transparent overlay with scanning box
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: ScannerOverlayPainter(scanBoxSize: scanBoxSize),
          ),
        ],
      ),
    );
  }

  String? extractClassId(String? qrData) {
    if (qrData == null) return null;
    if (qrData.startsWith('join:')) {
      return qrData.replaceFirst('join:', '');
    }
    return null;
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double scanBoxSize;
  final double cornerLength;
  final double strokeWidth;
  final Color cornerColor;

  ScannerOverlayPainter({
    required this.scanBoxSize,
    this.cornerLength = 30,
    this.strokeWidth = 4,
    this.cornerColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint cornerPaint = Paint()
      ..color = cornerColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double left = (size.width - scanBoxSize) / 2;
    final double top = (size.height - scanBoxSize) / 2;
    final double right = left + scanBoxSize;
    final double bottom = top + scanBoxSize;

    // Top-left corner
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerLength), cornerPaint);

    // Top-right corner
    canvas.drawLine(Offset(right, top), Offset(right - cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerLength), cornerPaint);

    // Bottom-left corner
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerLength, bottom), cornerPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - cornerLength), cornerPaint);

    // Bottom-right corner
    canvas.drawLine(Offset(right, bottom), Offset(right - cornerLength, bottom), cornerPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
