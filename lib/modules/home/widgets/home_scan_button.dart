import 'package:flutter/material.dart';
import 'package:frontend_mahasiswa/core/ui/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScanButton extends StatefulWidget {
  final VoidCallback? onTap;

  const HomeScanButton({super.key, required this.onTap});

  @override
  State<HomeScanButton> createState() => _HomeScanButtonState();
}

class _HomeScanButtonState extends State<HomeScanButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), 
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (widget.onTap != null) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant HomeScanButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onTap != null && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (widget.onTap == null) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onTap != null;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isEnabled 
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.bgGradient,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade600],
                  ),
              boxShadow: [
                if (isEnabled) 
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3 + (0.3 * _animation.value)),               
                    blurRadius: 3 + (12 * _animation.value),                 
                    spreadRadius: 0.1 + (2 * _animation.value), 
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner_rounded,
                size: 48,
                color: isEnabled ? AppColors.primaryBlue : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                "Scan QR",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}