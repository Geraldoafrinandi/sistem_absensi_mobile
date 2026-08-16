import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_mahasiswa/core/data/global_data.dart';
import 'package:frontend_mahasiswa/core/ui/widgets/attendance_status_dialog.dart';
import 'package:frontend_mahasiswa/modules/home/controllers/qr_scanner_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend_mahasiswa/core/ui/widgets/custom_snackbar.dart';
import 'package:frontend_mahasiswa/modules/home/data/schedule_model.dart';

class QrScannerPage extends StatefulWidget {
  final ScheduleModel? activeSession;
  const QrScannerPage({super.key, this.activeSession});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController cameraController = MobileScannerController();
  bool isScanCompleted = false;

  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  void _processFinalScan(String code) async {
    if (isScanCompleted) return;

    setState(() => isScanCompleted = true);

    // await cameraController.stop();

    Position? position = GlobalData.currentPosition;
    position ??= await Geolocator.getLastKnownPosition(
      forceAndroidLocationManager: true,
    );

    if (position != null && widget.activeSession?.latitudeDosen != null) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.activeSession!.latitudeDosen!,
        widget.activeSession!.longitudeDosen!,
      );

      double radius = (widget.activeSession!.radiusIzin ?? 20).toDouble();

      if (distance > radius) {
        if (mounted) {
          AttendanceStatusDialog.show(
            context,
            isSuccess: false,
            message: "Luar Jangkauan",
            subMessage:
                "Jarak Anda: ${distance.toStringAsFixed(0)}m (Max: ${radius.toInt()}m)",
          );
          setState(() => isScanCompleted = false);
          cameraController.start();
          return;
        }
      }
    }

    if (mounted) {
      QrScannerController.processScannedQR(
        context: context,
        scannedToken: code,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      ),
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.width * 0.7,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            scanWindow: scanWindow,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && !isScanCompleted) {
                _processFinalScan(barcodes.first.rawValue ?? "Unknown");
              }
            },
          ),
          _buildScannerOverlay(context),
          _buildScanAnimation(scanWindow),
          SafeArea(
            child: Column(
              children: [_buildHeader(context), const Spacer(), _buildFooter()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanAnimation(Rect scanWindow) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: scanWindow.top + (scanWindow.height * _animation.value),
          left: scanWindow.left + 20,
          right: scanWindow.left + 20,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B4EFF).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              gradient: const LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFF6B4EFF),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: const Color(0xFF6B4EFF),
          borderRadius: 30,
          borderLength: 40,
          borderWidth: 8,
          cutOutSize: MediaQuery.of(context).size.width * 0.7,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleBtn(
            icon: Icons.close,
            onTap: () => Navigator.pop(context),
          ),
          Text(
            "PRESENSI MAHASISWA",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontSize: 14,
            ),
          ),
          ValueListenableBuilder(
            valueListenable: cameraController,
            builder: (context, state, child) {
              return _buildCircleBtn(
                icon: state.torchState == TorchState.on
                    ? Icons.flash_on
                    : Icons.flash_off,
                color: state.torchState == TorchState.on
                    ? Colors.yellow
                    : Colors.white,
                onTap: () => cameraController.toggleTorch(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_scanner, color: Color(0xFF6B4EFF), size: 30),
          const SizedBox(height: 12),
          Text(
            "Tempatkan Kode QR di dalam kotak",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Proses verifikasi jarak dilakukan saat QR terdeteksi",
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final center = rect.center;

    final cutOutRect = Rect.fromCenter(
      center: center,
      width: cutOutSize,
      height: cutOutSize,
    );

    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(
          RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        ),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final borderPath = Path();

    borderPath.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    borderPath.lineTo(cutOutRect.left, cutOutRect.top + borderRadius);
    borderPath.arcToPoint(
      Offset(cutOutRect.left + borderRadius, cutOutRect.top),
      radius: Radius.circular(borderRadius),
    );
    borderPath.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    borderPath.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    borderPath.lineTo(cutOutRect.right - borderRadius, cutOutRect.top);
    borderPath.arcToPoint(
      Offset(cutOutRect.right, cutOutRect.top + borderRadius),
      radius: Radius.circular(borderRadius),
    );
    borderPath.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    borderPath.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    borderPath.lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius);
    borderPath.arcToPoint(
      Offset(cutOutRect.right - borderRadius, cutOutRect.bottom),
      radius: Radius.circular(borderRadius),
    );
    borderPath.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    borderPath.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    borderPath.lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom);
    borderPath.arcToPoint(
      Offset(cutOutRect.left, cutOutRect.bottom - borderRadius),
      radius: Radius.circular(borderRadius),
    );
    borderPath.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
