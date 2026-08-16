import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:frontend_mahasiswa/modules/home/widgets/home_sliver_app_bar.dart';
import 'package:frontend_mahasiswa/core/services/storage_service.dart';
import 'package:frontend_mahasiswa/core/data/endpoint_api.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'data/history_model.dart';
import 'widgets/history_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage>
    with AutomaticKeepAliveClientMixin<HistoryPage> {
  int selectedStatusIndex = 0;
  final List<String> statuses = ['Semua', 'Hadir', 'Sakit', 'Izin', 'Alpha'];
  DateTime? selectedDate;

  bool isLoading = true;
  List<HistoryModel> histories = [];

  Map<String, String> summaryData = {
    'hadir': '0',
    'telat': '0',
    'sakit': '0',
    'alpha': '0',
    'persentase': '0%',
  };

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_refreshController.isRefresh) {
      _refreshController.refreshCompleted();
    }
  }

  Future<void> fetchRiwayat({bool isRefresh = false}) async {
    if (!mounted) return;

    if (!isRefresh) {
      setState(() => isLoading = true);
    }

    try {
      final token = await StorageService.getToken() ?? "";

      List<String> queryParams = [];
      if (selectedStatusIndex != 0) {
        queryParams.add("status=${statuses[selectedStatusIndex]}");
      }
      if (selectedDate != null) {
        String formattedDate =
            "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
        queryParams.add("tanggal=$formattedDate");
      }

      String urlString = EndpointApi.riwayatAbsensi;
      if (queryParams.isNotEmpty) {
        urlString += "?${queryParams.join('&')}";
      }

      final response = await http
          .get(
            Uri.parse(urlString),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final data = result['data'];

        if (mounted) {
          setState(() {
            summaryData = {
              'hadir': data['summary']['hadir'].toString(),
              'telat': data['summary']['telat'].toString(),
              'sakit': data['summary']['sakit'].toString(),
              'alpha': data['summary']['alpha'].toString(),
              'persentase': data['summary']['persentase'].toString(),
            };

            List<dynamic> historyList = data['histories'] ?? [];
            histories = historyList
                .map((item) => HistoryModel.fromJson(item))
                .toList();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            histories = [];
            summaryData = {
              'hadir': '0',
              'telat': '0',
              'sakit': '0',
              'alpha': '0',
              'persentase': '0%',
            };
          });
        }
        debugPrint("API ERROR CODE: ${response.statusCode}");
      }

      _refreshController.refreshCompleted();
    } catch (e) {
      debugPrint("Error Fetch Riwayat: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
      }
      _refreshController.refreshFailed();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _getCurrentSemester() {
    DateTime now = DateTime.now();
    return now.month >= 8 || now.month == 1
        ? "Semester Ganjil ${now.year}/${now.year + 1}"
        : "Semester Genap ${now.year - 1}/${now.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2024),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B4EFF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchRiwayat();
    }
  }

  void _clearDateFilter() {
    setState(() => selectedDate = null);
    fetchRiwayat();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          const HomeSliverAppBar(appBarHeight: 200.0),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Riwayat Absensi",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getCurrentSemester(),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSummaryCard(),
                const SizedBox(height: 32),
                _buildSectionHeader(context),
                const SizedBox(height: 8),
                _buildFilterChips(),
                const SizedBox(height: 16),
              ],
            ),
          ),

          if (isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: Color(0xFF6B4EFF)),
                ),
              ),
            )
          else if (histories.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text(
                    "Belum ada riwayat absensi",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => HistoryCard(data: histories[index]),
                  childCount: histories.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Daftar Hadir",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              if (selectedDate != null)
                GestureDetector(
                  onTap: _clearDateFilter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.close, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () => _selectDate(context),
            icon: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF6B4EFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4EFF).withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBadgeItem(
            summaryData['hadir']!,
            "Hadir",
            const Color(0xFF10B981),
          ),
          _buildBadgeItem(
            summaryData['telat']!,
            "Telat",
            const Color(0xFFF59E0B),
          ),
          _buildBadgeItem(
            summaryData['sakit']!,
            "Sakit",
            const Color(0xFF3B82F6),
          ),
          _buildBadgeItem(
            summaryData['alpha']!,
            "Alpha",
            const Color(0xFFEF4444),
          ),
          _buildBadgeItem(
            summaryData['persentase']!,
            "Total",
            const Color(0xFF6B4EFF),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(statuses.length, (index) {
          bool isSelected = selectedStatusIndex == index;
          return GestureDetector(
            onTap: () {
              if (selectedStatusIndex != index) {
                setState(() => selectedStatusIndex = index);
                fetchRiwayat();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4285F4) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
              ),
              child: Text(
                statuses[index],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
