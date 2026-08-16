import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_mahasiswa/core/data/global_data.dart';
import 'package:frontend_mahasiswa/core/services/location_services.dart';
import 'package:frontend_mahasiswa/core/ui/widgets/custom_snackbar.dart';
import 'package:frontend_mahasiswa/core/ui/widgets/gps_indicator_widget.dart';
import 'package:frontend_mahasiswa/modules/auth/login_pages.dart';
import 'package:frontend_mahasiswa/modules/home/permission_screen.dart';
import 'package:frontend_mahasiswa/modules/home/widgets/permission_button.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

import 'package:frontend_mahasiswa/core/services/storage_service.dart';
import 'package:frontend_mahasiswa/core/data/endpoint_api.dart';
import 'package:frontend_mahasiswa/core/ui/app_colors.dart';

import 'package:frontend_mahasiswa/modules/home/widgets/qr_scanner_page.dart';
import 'package:frontend_mahasiswa/modules/schedule/all_courses_page.dart';
import 'package:frontend_mahasiswa/modules/home/data/schedule_model.dart';
import 'package:frontend_mahasiswa/modules/home/widgets/home_stats_card.dart';
import 'package:frontend_mahasiswa/modules/home/widgets/home_scan_button.dart';
import 'package:frontend_mahasiswa/modules/home/widgets/home_schedule_item.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<ScheduleModel> todaySchedules = [];
  bool isLoading = true;

  bool isLoadingSchedules = true;
  ScheduleModel? activeSession;
  String nama = "...";
  String nim = "...";
  String kelasId = "...";

  bool _isInRange = false;

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  final GlobalKey<HomeStatsCardState> statsCardKey =
      GlobalKey<HomeStatsCardState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    LocationService.startTracking().catchError((e) {
      debugPrint("Gagal mengaktifkan tracking lokasi: $e");
    });

    _initData();
  }

  Future<void> refreshAllData() async {
    if (!mounted) return;

    setState(() {
      isLoadingSchedules = true;
      isLoading = true;
    });

    try {
      await Future.wait([
        _checkLocationPermission(),
        _loadUserData(),
        _fetchTodaySchedules(),
        () async {
          try {
            await statsCardKey.currentState?.loadDashboardStats();
          } catch (e) {
            debugPrint("Stats card refresh skipped: $e");
          }
        }(),
      ]);

      if (mounted) {
        setState(() {
          isLoadingSchedules = false;
          isLoading = false;
        });
      }
      _refreshController.refreshCompleted();
    } catch (e) {
      debugPrint("Error refresh all data: $e");

      if (mounted) {
        setState(() {
          isLoadingSchedules = false;
          isLoading = false;
        });
        CustomSnackBar.showError(context, "Gagal memperbarui data.");
      }
      _refreshController.refreshFailed();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      StorageService.saveLastActiveTime();
    } else if (state == AppLifecycleState.resumed) {
      _checkSessionTimeout();
    }
  }

 Future<void> _checkSessionTimeout() async {
  final lastActive = await StorageService.getLastActiveTime();
  if (lastActive == null) return;

  const int timeoutLimitInMinutes = 15;
  final int elapsedMinutes = DateTime.now().difference(lastActive).inMinutes;

  if (elapsedMinutes >= timeoutLimitInMinutes) {
    await StorageService.clearAuthData();
    await StorageService.removeLastActiveTime();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/login', 
        (route) => false,
      );
    }
  }
}

  Future<void> _initData() async {
    await refreshAllData();
  }

  Future<void> _loadUserData() async {
    final results = await Future.wait([
      StorageService.getNamaKey(),
      StorageService.getNim(),
      StorageService.getNamaKelas(),
    ]);
    if (mounted) {
      setState(() {
        nama = results[0] ?? "Mahasiswa";
        nim = results[1] ?? "-";
        kelasId = results[2] ?? "-";
      });
    }
  }

  Future<void> _fetchTodaySchedules() async {
    final token = await StorageService.getToken() ?? "";
    final response = await http
        .get(
          Uri.parse("${EndpointApi.jadwalMahasiswa}?filter=today"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final schedules = data.map((e) => ScheduleModel.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          todaySchedules = schedules;
          activeSession = schedules.cast<ScheduleModel?>().firstWhere(
            (s) => s?.isSessionActive ?? false,
            orElse: () => null,
          );
        });
      }
    } else {
      throw Exception("Gagal mengambil data jadwal dari server");
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showGPSDialog();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
  }

  void _showGPSDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.location_off, color: Colors.red),
              const SizedBox(width: 10),
              Text(
                "GPS Tidak Aktif",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            "Untuk melakukan presensi, perangkat Anda wajib mengaktifkan GPS agar sistem bisa memverifikasi lokasi Anda.",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              child: Text(
                "Buka Pengaturan",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6B4EFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateRangeStatus(Position pos) {
    if (activeSession?.latitudeDosen == null) return;
    double distance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      activeSession!.latitudeDosen!,
      activeSession!.longitudeDosen!,
    );
    bool reachable = distance <= (activeSession!.radiusIzin ?? 20);

    if (_isInRange != reachable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isInRange = reachable;
            isLoading = false;
          });
        }
      });
    }
  }

  void _handleScanAction() {
    if (activeSession == null) {
      CustomSnackBar.showError(
        context,
        "Belum ada sesi presensi yang dibuka oleh dosen!",
      );
      return;
    }
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QrScannerPage(activeSession: activeSession),
        ),
      );
    }
  }

  void _handlePermitAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormIzinScreen(
          idSesi: activeSession!.sesiId.toString(),
          namaMatkul: activeSession!.subject.toString(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.zero,
      children: [
        _buildGradientHeader(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildScanCard(),
              const SizedBox(height: 24),
              _buildSectionTitle("Jadwal Hari Ini"),
              const SizedBox(height: 16),
              _buildScheduleContent(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanCard() {
    bool hasSesi = activeSession != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D69C1).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Absensi Mahasiswa",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isLoadingSchedules
                ? "Mengecek status sesi..."
                : hasSesi
                ? "Sesi Aktif: ${activeSession!.subject}"
                : "Belum ada sesi presensi dibuka",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: hasSesi ? Colors.green : Colors.red,
              fontWeight: hasSesi ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),

          if (hasSesi) _buildLiveDistance() else const SizedBox(height: 20),

          HomeScanButton(onTap: hasSesi ? () => _handleScanAction() : null),
          const SizedBox(height: 8),

          if (hasSesi) ...[
            const SizedBox(height: 8),
            HomePermitButton(onTap: () => _handlePermitAction()),
          ],

          Text(
            "Pastikan GPS aktif dan anda berada di dalam area kelas untuk melakukan presensi.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveDistance() {
    if (activeSession?.latitudeDosen == null || activeSession?.longitudeDosen == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 2)),
      builder: (context, snapshot) {
        if (!GlobalData.isGpsReady.value || GlobalData.latitude == null) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              "Menunggu Lokasi Akurat...",
              style: GoogleFonts.poppins(
                fontSize: 12, 
                color: Colors.grey, 
                fontWeight: FontWeight.bold
              ),
            ),
          );
        }

        double distance = Geolocator.distanceBetween(
          GlobalData.latitude!,
          GlobalData.longitude!,
          activeSession!.latitudeDosen!,
          activeSession!.longitudeDosen!,
        );

        bool isInRange = distance <= (activeSession!.radiusIzin ?? 20);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 15),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: (isInRange ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: (isInRange ? Colors.green : Colors.red).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isInRange ? Icons.location_on : Icons.location_off,
                size: 16,
                color: isInRange ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isInRange
                    ? "Dalam Jangkauan (${distance.toStringAsFixed(0)}m)"
                    : "Luar Jangkauan (${distance.toStringAsFixed(0)}m)",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isInRange ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 320,
          width: double.infinity,
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
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildTopBar(), 
                const SizedBox(height: 30),
                _buildProfileInfo(),
                const SizedBox(height: 40),
                HomeStatsCard(key: statsCardKey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
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
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
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
    );
  }

  Widget _buildProfileInfo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Text(
              nama.isNotEmpty ? nama[0].toUpperCase() : "?",
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
                      "$nim . $kelasId",
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AllCoursesPage()),
          ),
          child: Text(
            "Lihat Semua",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B4EFF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleContent() {
    if (isLoadingSchedules) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (todaySchedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            "Tidak ada jadwal hari ini",
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: todaySchedules
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: HomeScheduleItem(data: s),
            ),
          )
          .toList(),
    );
  }
}