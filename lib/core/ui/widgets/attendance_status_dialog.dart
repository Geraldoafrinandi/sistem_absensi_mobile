import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class AttendanceStatusDialog extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final String? subMessage;

  const AttendanceStatusDialog({
    super.key,
    required this.isSuccess,
    required this.message,
    this.subMessage,
  });

  static void show(
    BuildContext context, {
    required bool isSuccess,
    required String message,
    String? subMessage,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AttendanceStatusDialog(
        isSuccess: isSuccess,
        message: message,
        subMessage: subMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final Color secondaryColor = isSuccess ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30), // Lebih membulat (modern)
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  isSuccess ? const AnimatedCheck() : const AnimatedCross(),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                isSuccess ? "Presensi Berhasil!" : "Presensi Gagal!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              if (subMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  subMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                  ),
                ),
              ],

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadowColor: primaryColor.withOpacity(0.4),
                  ).copyWith(
                    overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    "Oke",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class AnimatedCheck extends StatefulWidget {
  const AnimatedCheck({super.key});
  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(60, 60), 
        painter: CheckPainter(_controller),
      );
}

class CheckPainter extends CustomPainter {
  final Animation<double> animation;
  CheckPainter(this.animation) : super(repaint: animation);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.45, size.height * 0.75);
    path.lineTo(size.width * 0.85, size.height * 0.3);

    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final extractPath = metric.extractPath(
        0,
        metric.length * animation.value,
      );
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedCross extends StatefulWidget {
  const AnimatedCross({super.key});
  @override
  State<AnimatedCross> createState() => _AnimatedCrossState();
}

class _AnimatedCrossState extends State<AnimatedCross> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(50, 50),
        painter: CrossPainter(_controller),
      );
}

class CrossPainter extends CustomPainter {
  final Animation<double> animation;
  CrossPainter(this.animation) : super(repaint: animation);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.8);
    path.moveTo(size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width * 0.2, size.height * 0.8);

    for (var metric in path.computeMetrics()) {
      final extractPath = metric.extractPath(
        0,
        metric.length * animation.value,
      );
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}