import 'package:flutter/material.dart';
import 'package:frontend_mahasiswa/core/services/storage_service.dart';
import 'package:frontend_mahasiswa/core/ui/app_colors.dart';
import 'package:frontend_mahasiswa/core/ui/layout/main_layout.dart';
import 'package:frontend_mahasiswa/core/ui/widgets/custom_snackbar.dart';
import 'package:frontend_mahasiswa/modules/auth/controllers/auth_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_mahasiswa/core/ui/widgets/custom_text_field.dart';

class LoginPages extends StatefulWidget {
  const LoginPages({super.key});

  @override
  State<LoginPages> createState() => _LoginPagesState();
}

class _LoginPagesState extends State<LoginPages> {
  final AuthController _authController = AuthController();

  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    String nim = _nimController.text.trim();
    String password = _passwordController.text.trim();

    if (nim.isEmpty || password.isEmpty) {
      CustomSnackBar.showError(context, "NIM dan Password tidak boleh kosong!");
      return;
    }

    setState(() => _isLoading = true);

    final String? errorMessage = await _authController.login(nim, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (errorMessage == null) {
      final String? namaUser = await StorageService.getNamaKey();
      CustomSnackBar.showSuccess(context, "Selamat Datang, $namaUser!");

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    } else {
      CustomSnackBar.showError(context, errorMessage);
    }
  }

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: AppColors.bgGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: 32.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 75,
                            backgroundColor: Color(0xFFF3F4F6),
                            backgroundImage: AssetImage(
                              'assets/images/TekinfoBulat.png',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Selamat Datang !",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "HadirIn",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "Sistem Presensi Mahasiswa",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          CustomTextField(
                            label: "Nomor Induk Mahasiswa (NIM)",
                            controller: _nimController,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            label: "Password",
                            isPassword: _obscurePassword,
                            controller: _passwordController,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                "Lupa Password ?",
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Masuk",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Versi Aplikasi. v1.0.0",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),

                          // Row(
                          //   children: [
                          //     const Expanded(child: Divider(thickness: 1)),
                          //     Padding(
                          //       padding: const EdgeInsets.symmetric(horizontal: 10),
                          //       child: const Text("atau", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          //     ),
                          //     const Expanded(child: Divider(thickness: 1)),
                          //   ],
                          // ),

                          // const SizedBox(height: 16),

                          // // Tombol Scan QR
                          // SizedBox(
                          //   width: double.infinity,
                          //   height: 48,
                          //   child: ElevatedButton(
                          //     onPressed: () {},
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: AppColors.secondaryGreen,
                          //       foregroundColor: Colors.white,
                          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          //       elevation: 0,
                          //     ),
                          //     child: const Text("Scan QR Cepat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
