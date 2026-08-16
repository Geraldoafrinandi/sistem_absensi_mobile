import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mahasiswa/core/services/storage_service.dart';
import 'package:frontend_mahasiswa/core/ui/widgets/gps_indicator_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_mahasiswa/core/ui/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class HomeSliverAppBar extends StatefulWidget {
  final double appBarHeight;

  const HomeSliverAppBar({super.key, this.appBarHeight = 250.0});

  @override
  State<HomeSliverAppBar> createState() => _HomeSliverAppBarState();
}

class _HomeSliverAppBarState extends State<HomeSliverAppBar> {
  String nama = "...";
  String nim = "...";
  String kelas = "...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final results = await Future.wait([
        StorageService.getNamaKey(),
        StorageService.getNim(),
        StorageService.getNamaKelas(),
      ]);

      if (mounted) {
        setState(() {
          nama = results[0] ?? "Mahasiswa";
          nim = results[1] ?? "-";
          kelas = results[2] ?? "-";
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty || name == "...") return "?";
    return name.trim().split(' ').first[0].toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      expandedHeight: widget.appBarHeight,

      pinned: true,
      floating: true,

      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.bgGradient,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "HadirIn",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Sistem Presensi",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      
                      const GpsIndicatorWidget(isDarkBackground: true),
                      
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle,
                        ),

                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: _getAvatarColor(nama),
                          child: Text(
                            _getInitials(nama),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: isLoading
                            ? Shimmer.fromColors(
                                baseColor: Colors.white.withOpacity(0.3),
                                highlightColor: Colors.white.withOpacity(0.1),
                                period: const Duration(milliseconds: 1000),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 180,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Halo, $nama!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$nim . $kelas",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
