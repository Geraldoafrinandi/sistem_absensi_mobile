import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_mahasiswa/core/ui/app_colors.dart';
import 'package:frontend_mahasiswa/core/services/storage_service.dart';
import 'package:frontend_mahasiswa/core/data/endpoint_api.dart';

class HomeStatsCard extends StatefulWidget {
  const HomeStatsCard({super.key});

  @override
  State<HomeStatsCard> createState() => HomeStatsCardState();
}

class HomeStatsCardState extends State<HomeStatsCard> {
  bool _isLoading = true;

  String _hadir = "0";
  String _telat = "0";
  String _izin = "0";
  String _alpha = "0";
  String _persentaseText = "0%";
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final token = await StorageService.getToken() ?? "";
      final url = Uri.parse(EndpointApi.statistikMingguan);

      final response = await http
          .get(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final summary = result['data'];

        String pctStr = summary['persentase'] ?? "0%";
        double parsedValue = 0.0;
        try {
          parsedValue = double.parse(pctStr.replaceAll('%', '')) / 100.0;
        } catch (_) {}

        int totalIzin = int.tryParse(summary['izin']?.toString() ?? "0") ?? 0;
        int totalSakit = int.tryParse(summary['sakit']?.toString() ?? "0") ?? 0;
        int gabunganIzinSakit = totalIzin + totalSakit;

        if (mounted) {
          setState(() {
            _hadir = summary['hadir']?.toString() ?? "0";
            _telat = summary['telat']?.toString() ?? "0";
            _izin = gabunganIzinSakit.toString();
            _alpha = summary['alpha']?.toString() ?? "0";
            _persentaseText = pctStr;
            _progressValue = parsedValue;
            _isLoading = false;
          });
        }
      } else {
        debugPrint(
          "API mengembalikan status selain 200: ${response.statusCode}",
        );
        if (mounted) {
          setState(() {
            _hadir = "0";
            _telat = "0";
            _izin = "0";
            _alpha = "0";
            _persentaseText = "0%";
            _progressValue = 0.0;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal memuat statistik dashboard: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D69C1).withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: _isLoading
            ? const SizedBox(
                height: 140,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Statistik Absensi",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Per Minggu",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _buildItem(
                        _hadir,
                        "Hadir",
                        const Color(0xFF22C55E),
                        const Color(0xFFDCFCE7),
                      ),
                      _buildItem(
                        _telat,
                        "Terlambat",
                        const Color(0xFFEAB308),
                        const Color(0xFFFEF9C3),
                      ),
                      _buildItem(
                        _izin,
                        "Izin & Sakit",
                        const Color(0xFF3B82F6),
                        const Color(0xFFDBEAFE),
                      ),
                      _buildItem(
                        _alpha,
                        "Alpha",
                        const Color(0xFFEF4444),
                        const Color(0xFFFEE2E2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tingkat Kehadiran",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _persentaseText,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFF3F4F6),
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildItem(String val, String label, Color color, Color bg) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    val,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
