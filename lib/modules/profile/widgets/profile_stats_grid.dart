import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_mahasiswa/core/services/storage_service.dart';
import 'package:frontend_mahasiswa/core/data/endpoint_api.dart';

class ProfileStatsGrid extends StatefulWidget {
  const ProfileStatsGrid({super.key});

  @override
  State<ProfileStatsGrid> createState() => _ProfileStatsGridState();
}

class _ProfileStatsGridState extends State<ProfileStatsGrid> {
  bool _isLoading = true;

  String _rataRata = "0%";
  String _totalHadir = "0";
  String _totalMatkul = "0";
  String _ketidakhadiran = "0";

  @override
  void initState() {
    super.initState();
    _fetchProfileStats();
  }

  Future<void> _fetchProfileStats() async {
    try {
      final token = await StorageService.getToken() ?? "";
      final url = Uri.parse(EndpointApi.statistikProfil);

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final stats = result['data'];

        setState(() {
          _rataRata = stats['rataRata'] ?? "0%";

          _totalHadir = stats['totalHadir']?.toString() ?? "0";
          _totalMatkul = stats['totalMatkul']?.toString() ?? "0";
          _ketidakhadiran = stats['ketidakhadiran']?.toString() ?? "0";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Profile Stats: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatBox(
          "Rata - Rata Kehadiran",
          _rataRata,
          const Color(0xFF10B981),
          Icons.analytics_rounded,
        ),
        _buildStatBox(
          "Total Kehadiran",
          _totalHadir,
          const Color(0xFF3B82F6),
          Icons.fact_check_rounded,
        ),
        _buildStatBox(
          "Mata Kuliah",
          _totalMatkul,
          const Color(0xFFF59E0B),
          Icons.book_rounded,
        ),
        _buildStatBox(
          "Ketidakhadiran",
          _ketidakhadiran,
          const Color(0xFFEF4444),
          Icons.cancel_presentation_rounded,
        ),
      ],
    );
  }

  Widget _buildStatBox(String title, String value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: color.withOpacity(0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: 3,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
