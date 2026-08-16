import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mahasiswa/modules/home/widgets/home_sliver_app_bar.dart';
import 'package:frontend_mahasiswa/modules/schedule/data/course_schedule_model.dart';
import 'package:frontend_mahasiswa/modules/schedule/widgets/schedule_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/schedule_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int selectedDayIndex = 0;
  List<CourseScheduleModel> _allSchedules = [];
  bool _isLoading = true;

  final List<String> _staticDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  List<String> dynamicDays = [];

  @override
  void initState() {
    super.initState();
    _generateDynamicDays();
    _fetchData();
  }

  void _generateDynamicDays() {
    DateTime now = DateTime.now();
    int todayIndex = now.weekday - 1;

    List<String> tempDays = [];
    for (int i = 0; i < 7; i++) {
      int index = (todayIndex + i) % 7;
      tempDays.add(_staticDays[index]);
    }

    setState(() {
      dynamicDays = tempDays;
      selectedDayIndex = 0;
    });
  }

  Future<void> _fetchData() async {
    try {
      final data = await ScheduleService.getMySchedules();
      setState(() {
        _allSchedules = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<CourseScheduleModel> get _filteredSchedules {
    if (_allSchedules.isEmpty || dynamicDays.isEmpty) return [];
    String targetDayName = dynamicDays[selectedDayIndex];
    return _allSchedules
        .where(
          (s) => s.hari.trim().toLowerCase() == targetDayName.toLowerCase(),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime displayDate = now.add(Duration(days: selectedDayIndex));
    String formattedDate = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(displayDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const HomeSliverAppBar(appBarHeight: 200.0),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderWithAnimation(formattedDate),
                  const SizedBox(height: 24),
                  _buildRollingDaySelector(),
                ],
              ),
            ),
          ),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _filteredSchedules.isEmpty
              ? _buildEmptyState()
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAnimatedCard(index),
                      childCount: _filteredSchedules.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithAnimation(String dateText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Jadwal Kuliah",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1E2D),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                dateText,
                key: ValueKey(dateText),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF6B4EFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        // _buildCalendarButton(),
      ],
    );
  }

  // Widget _buildCalendarButton() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           // ignore: deprecated_member_use
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: IconButton(
  //       icon: const Icon(
  //         Icons.calendar_today_rounded,
  //         color: Color(0xFF6B4EFF),
  //         size: 20,
  //       ),
  //       onPressed: () {
  //         HapticFeedback.lightImpact();
  //       },
  //     ),
  //   );
  // }

  Widget _buildRollingDaySelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dynamicDays.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedDayIndex == index;
          String dayName = dynamicDays[index];
          bool isSunday = dayName == 'Minggu';

          bool isToday = index == 0;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => selectedDayIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 65,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isSunday ? Colors.redAccent : const Color(0xFF6B4EFF))
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  border: isToday
                      ? Border.all(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B4EFF),
                          width: 2,
                        )
                      : Border.all(color: Colors.transparent, width: 2),

                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                (isSunday
                                        ? Colors.redAccent
                                        : const Color(0xFF6B4EFF))
                                    // ignore: deprecated_member_use
                                    .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName.substring(0, 3),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: isToday || isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isSunday ? Colors.redAccent : Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // if (isToday)
                    //   Text(
                    //     "Hari ini",
                    //     style: GoogleFonts.poppins(
                    //       fontSize: 8,
                    //       fontWeight: FontWeight.bold,
                    //       color: isSelected
                    //           ? Colors.white
                    //           : const Color(0xFF6B4EFF),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedCard(int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: ScheduleCard(data: _filteredSchedules[index]),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_motion_rounded,
                size: 60,
                color: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tidak ada jadwal kuliah untuk hari ini.",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
