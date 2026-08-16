import 'package:flutter/material.dart';
import 'package:frontend_mahasiswa/modules/home/data/schedule_model.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScheduleItem extends StatelessWidget {
  final ScheduleModel data;
  const HomeScheduleItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isClosed = data.status == "Tutup";

    final Color currentThemeColor = data.statusColor;
    final String displayStatus = data.status == "Tutup"
        ? "SELESAI"
        : data.status.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: currentThemeColor, 
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.subject,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: data.status == "Tutup" ? Colors.grey : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.access_time_rounded, data.time),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.person_outline_rounded, data.lecturer),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.location_on_outlined, data.room),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: currentThemeColor.withOpacity(
                0.1,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: currentThemeColor.withOpacity(0.5)),
            ),
            child: Text(
              displayStatus,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color:
                    currentThemeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildInfoRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 14, color: Colors.grey[600]),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
