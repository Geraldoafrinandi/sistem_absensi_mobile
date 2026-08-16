import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/course_schedule_model.dart';

class ScheduleCard extends StatelessWidget {
  final CourseScheduleModel data;

  const ScheduleCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 75,
            decoration: BoxDecoration(
              color: data.themeColor,
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
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  Icons.access_time_rounded,
                  "${data.startTime} - ${data.endTime}",
                ),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.person_outline_rounded, data.lecturer),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  data.room,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: data.themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: data.themeColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              "${data.sks} SKS",
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: data.themeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}