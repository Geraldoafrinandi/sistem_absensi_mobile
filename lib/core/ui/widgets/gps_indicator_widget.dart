import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_mahasiswa/core/data/global_data.dart';

class GpsIndicatorWidget extends StatelessWidget {
  final bool isDarkBackground; 

  const GpsIndicatorWidget({
    super.key, 
    this.isDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: GlobalData.isGpsReady,
      builder: (context, isReady, child) {
        
        final Color textColor = isDarkBackground ? Colors.white70 : Colors.grey.shade700;
        final Color greenColor = isDarkBackground ? Colors.greenAccent : Colors.green;
        final Color bgColor = isDarkBackground 
            ? Colors.white.withOpacity(0.15) 
            : Colors.grey.withOpacity(0.1);

        if (isReady) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.satellite_alt, color: greenColor, size: 12),
                const SizedBox(width: 4),
                Text(
                  "Akurat",
                  style: GoogleFonts.poppins(
                    color: greenColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Mencari GPS...",
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}