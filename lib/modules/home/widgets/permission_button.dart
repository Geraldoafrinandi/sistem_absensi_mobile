import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePermitButton extends StatelessWidget {
  final VoidCallback? onTap;

  const HomePermitButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isEnabled ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEnabled ? Colors.blue.withOpacity(0.3) : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              if (isEnabled)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isEnabled 
                      ? Colors.blue.withOpacity(0.1) 
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment_turned_in_rounded,
                  color: isEnabled ? Colors.blue : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ajukan Izin / Sakit",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isEnabled ? Colors.black87 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isEnabled ? Colors.blue : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}