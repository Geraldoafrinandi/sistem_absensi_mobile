import 'package:flutter/material.dart';
import 'package:frontend_mahasiswa/core/ui/widgets/custom_snackbar.dart';
import 'package:frontend_mahasiswa/modules/auth/controllers/auth_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_mahasiswa/modules/home/widgets/home_sliver_app_bar.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_stats_grid.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {

int _refreshCounter = 0;

  bool isNotifActive = true;
  bool isReminderActive = true;

  Future<void> refreshProfilePage() async {
    if (mounted) {
      setState(() {
        _refreshCounter++; 
      });
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          const HomeSliverAppBar(appBarHeight: 200.0),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const ProfileInfoCard(),
                const SizedBox(height: 32),
                
                Text(
                  "Statistik Kehadiran",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                
                // const ProfileStatsGrid(),
                ProfileStatsGrid(key: ValueKey(_refreshCounter)),
                const SizedBox(height: 32),
                _buildSecuritySection(), 
                
                // const SizedBox(height: 24),
                // _buildSettingsSection(),
                
                const SizedBox(height: 40),
                _buildLogoutButton(),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Keamanan Akun",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: ListTile(
            onTap: () => _showChangePasswordDialog(context),
            leading: const Icon(Icons.lock_outline, color: Color(0xFF6B4EFF)),
            title: Text(
              "Ubah Password",
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          ),
        ),
      ],
    );
  }

  // Widget _buildSettingsSection() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white, 
  //       borderRadius: BorderRadius.circular(24),
  //       border: Border.all(color: Colors.grey.shade300, width: 2.0),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 12,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             const Icon(Icons.settings_suggest_rounded, color: Color(0xFF6B4EFF), size: 22),
  //             const SizedBox(width: 8),
  //             Text(
  //               "Pengaturan Aplikasi",
  //               style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         _buildSwitchTile(
  //           "Notifikasi Push", 
  //           "Terima Notifikasi Jadwal Kuliah", 
  //           isNotifActive, 
  //           (val) => setState(() => isNotifActive = val),
  //           Icons.notifications_active_outlined,
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 8),
  //           child: Divider(color: Colors.grey.shade200, thickness: 1),
  //         ),
  //         _buildSwitchTile(
  //           "Reminder Absensi", 
  //           "Ingatkan 15 menit sebelum kelas", 
  //           isReminderActive, 
  //           (val) => setState(() => isReminderActive = val),
  //           Icons.alarm_on_rounded,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSwitchTile(String title, String sub, bool val, Function(bool) onChanged, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF6B4EFF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF6B4EFF), size: 20),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
      trailing: Switch(
        value: val,
        onChanged: onChanged,
        activeColor: const Color(0xFF6B4EFF),
        activeTrackColor: const Color(0xFF6B4EFF).withOpacity(0.2),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Ubah Password", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text("Pastikan password baru Anda kuat & aman", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF6B4EFF).withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.security_rounded, color: Color(0xFF6B4EFF), size: 20),
                        )
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    _buildEnhancedPasswordField("Password Lama", Icons.lock_open_rounded),
                    const SizedBox(height: 20),
                    _buildEnhancedPasswordField("Password Baru", Icons.lock_outline_rounded),
                    const SizedBox(height: 20),
                    _buildEnhancedPasswordField("Konfirmasi Password Baru", Icons.enhanced_encryption_rounded),
                    
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: Colors.amber.shade900),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Gunakan minimal 8 karakter dengan kombinasi huruf dan angka.",
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSubmitButton(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPasswordField(String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        ),
        TextField(
          obscureText: true,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6B4EFF)),
            suffixIcon: const Icon(Icons.visibility_off_outlined, size: 18, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4EFF).withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B4EFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          "PERBARUI PASSWORD",
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFF5C67).withOpacity(0.05), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF5C67), width: 2.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _showLogoutConfirmation(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: Color(0xFFFF5C67), size: 22),
              const SizedBox(width: 12),
              Text(
                "KELUAR DARI AKUN",
                style: GoogleFonts.poppins(
                  fontSize: 14, 
                  fontWeight: FontWeight.w800, 
                  color: const Color(0xFFFF5C67),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Konfirmasi Logout", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin keluar dari akun HadirIn?", 
          style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5C67),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);

              final authController = AuthController();
              bool success = await authController.logout();

              if (success) {
                if (!context.mounted) return;

                CustomSnackBar.showSuccess(context, "Berhasil keluar dari akun");

                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/login', 
                  (route) => false,
                );
              } else {
                if (!context.mounted) return;
                CustomSnackBar.showError(context, "Gagal logout, coba lagi");
              }
            },
            child: Text("Ya, Keluar", 
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}
}