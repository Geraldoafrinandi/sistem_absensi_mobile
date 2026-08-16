import 'package:flutter/material.dart';
import 'package:frontend_mahasiswa/core/services/storage_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileInfoCard extends StatefulWidget {
  const ProfileInfoCard({super.key});

  @override
  State<ProfileInfoCard> createState() => _ProfileInfoCardState();
}

class _ProfileInfoCardState extends State<ProfileInfoCard> {
  String nama = "...";
  String nim = "...";
  String kelas = "...";
  String tahunAngkatan = "-";
  String email = "-";
  String telepon = "-";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final storedNama = await StorageService.getNamaKey();
    final storedNim = await StorageService.getNim();
    final storedKelas = await StorageService.getNamaKelas();
    final storedAngkatan = await StorageService.getTahunAngkatan();
    final storedEmail = await StorageService.getEmail();
    final storedTelepon = await StorageService.getTelepon();

    if (mounted) {
      setState(() {
        nama = storedNama ?? "Mahasiswa";
        nim = storedNim ?? "-";
        kelas = storedKelas ?? "-";
        tahunAngkatan = storedAngkatan ?? "-";
        email = storedEmail ?? "-";
        telepon = storedTelepon ?? "-";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade300, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 40),
              _buildProfilePicture(context),
              _buildEditDataButton(context),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            nama,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            kelas,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1, thickness: 1.5, color: Color(0xFFF1F1F1)),
          ),

          _buildInfoRow(Icons.badge_outlined, "NIM", nim, isLocked: true),
          _buildInfoRow(Icons.school_outlined, "Tahun Angkatan", tahunAngkatan, isLocked: true),
          _buildInfoRow(Icons.email_outlined, "Email", email),
          _buildInfoRow(Icons.phone_android_rounded, "Telepon", telepon),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context) {
    String getInitials(String name) {
      if (name.isEmpty || name == "...") return "?";
      return name[0].toUpperCase();
    }

    Color getAvatarColor(String name) {
      final colors = [
        const Color(0xFF6B4EFF),
        Colors.orange.shade400,
        Colors.teal.shade400,
        Colors.pink.shade400,
        Colors.blue.shade400,
      ];
      return colors[name.hashCode.abs() % colors.length];
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF6B4EFF), width: 2.5),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: getAvatarColor(nama),
            child: Text(
              getInitials(nama),
              style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // GestureDetector(
        //   onTap: () => _showEditPhotoOptions(context),
        //   child: Container(
        //     padding: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color: const Color(0xFF6B4EFF),
        //       shape: BoxShape.circle,
        //       border: Border.all(color: Colors.white, width: 3),
        //     ),
        //     child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildEditDataButton(BuildContext context) {
    return IconButton(
      onPressed: () => _showEditDataSheet(context),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF6B4EFF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.edit_note_rounded,
          color: Color(0xFF6B4EFF),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isLocked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6B4EFF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isLocked ? Colors.grey : const Color(0xFF6B4EFF),
            ),
          ),
          const SizedBox(width: 12),

          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isLocked ? Colors.grey : Colors.black87,
              ),
            ),
          ),

          if (isLocked) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.lock_outline_rounded,
              size: 12,
              color: Colors.grey,
            ),
          ],
        ],
      ),
    );
  }

  void _showEditDataSheet(BuildContext context) {
    final nameController = TextEditingController(text: nama);
    final tahunAngkatanController = TextEditingController(text: tahunAngkatan);
    final emailController = TextEditingController(text: email);
    final phoneController = TextEditingController(text: telepon);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Edit Profil",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildFancyField(
                      label: "NIM",
                      icon: Icons.lock_person_rounded,
                      controller: TextEditingController(text: nim),
                      enabled: false,
                    ),

                  

                    const SizedBox(height: 16),
                    _buildFancyField(
                      label: "Tahun Angkatan",
                      icon: Icons.school_outlined,
                      controller: tahunAngkatanController,
                      enabled: false
                    ),

                      const SizedBox(height: 16),
                    _buildFancyField(
                      label: "Nama Lengkap",
                      icon: Icons.person_outline_rounded,
                      controller: nameController,
                    ),

                    const SizedBox(height: 16),
                    _buildFancyField(
                      label: "Email Mahasiswa",
                      icon: Icons.email_outlined,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),
                    _buildFancyField(
                      label: "Nomor Telepon",
                      icon: Icons.phone_android_rounded,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 32),

                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B4EFF).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            nama = nameController.text;
                            // prodi = prodiController.text;
                            email = emailController.text;
                            // telepon = phoneController.text;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profil berhasil diperbarui!"),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B4EFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Simpan Perubahan",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildFancyField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.grey[700] : Colors.grey[400],
            ),
          ),
        ),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 20,
              color: enabled ? const Color(0xFF6B4EFF) : Colors.grey,
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  // void _showEditPhotoOptions(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  //     builder: (context) => Container(
  //       padding: const EdgeInsets.all(24),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text("Ubah Foto Profil", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
  //           const SizedBox(height: 24),
  //           ListTile(
  //             leading: const Icon(Icons.photo_library_outlined),
  //             title: const Text("Pilih dari Galeri"),
  //             onTap: () => Navigator.pop(context),
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.camera_alt_outlined),
  //             title: const Text("Ambil Foto Baru"),
  //             onTap: () => Navigator.pop(context),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
