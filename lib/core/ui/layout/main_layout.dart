import 'package:flutter/material.dart';
import 'package:frontend_mahasiswa/core/ui/app_colors.dart';
import 'package:frontend_mahasiswa/modules/history/history_page.dart';
import 'package:frontend_mahasiswa/modules/home/home_page.dart';
import 'package:frontend_mahasiswa/modules/profile/profile_page.dart';
import 'package:frontend_mahasiswa/modules/schedule/schedule_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart' hide RefreshIndicator;

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final RefreshController _globalRefreshController = RefreshController(
    initialRefresh: false,
  );

  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();
  final GlobalKey<HistoryPageState> _historyKey = GlobalKey<HistoryPageState>();
  final GlobalKey<ProfilePageState> _profileKey = GlobalKey<ProfilePageState>();

  Future<void> _handleGlobalRefresh() async {
    try {
      final List<Future<void>> refreshTasks = [];

      if (_homeKey.currentState != null) {
        refreshTasks.add(_homeKey.currentState!.refreshAllData());
      }

      if (_historyKey.currentState != null) {
        refreshTasks.add(
          _historyKey.currentState!.fetchRiwayat(isRefresh: true),
        );
      }

      if (_profileKey.currentState != null) {
        refreshTasks.add(_profileKey.currentState!.refreshProfilePage());
      }

      if (refreshTasks.isNotEmpty) {
        await Future.wait(refreshTasks);
      }

      _globalRefreshController.refreshCompleted();
    } catch (e) {
      debugPrint("Global Refresh Error: $e");
      _globalRefreshController.refreshFailed();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const SchedulePage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(key: _homeKey),
      const SchedulePage(),
      HistoryPage(key: _historyKey),
      ProfilePage(key: _profileKey),
    ];
    return Scaffold(
    body: RefreshIndicator(
      color: AppColors.primaryBlue,
      backgroundColor: Colors.white,
      strokeWidth: 3.0,
      onRefresh: _handleGlobalRefresh,
      
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification.depth != 0) return true;
          return false;
        },
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
    ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onItemTapped,

          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey[400],

          showSelectedLabels: true,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule_outlined),
              activeIcon: Icon(Icons.schedule),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
