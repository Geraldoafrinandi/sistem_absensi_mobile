import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_mahasiswa/core/data/endpoint_api.dart';
import 'package:frontend_mahasiswa/core/ui/widgets/custom_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_mahasiswa/modules/home/widgets/custom_dropdown_field.dart';
import 'package:frontend_mahasiswa/core/ui/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormIzinScreen extends StatefulWidget {
  final String idSesi;
  final String namaMatkul;

  const FormIzinScreen({
    super.key,
    required this.idSesi,
    required this.namaMatkul,
  });

  @override
  State<FormIzinScreen> createState() => _FormIzinScreenState();
}

class _FormIzinScreenState extends State<FormIzinScreen> {
  String _statusKehadiran = 'Sakit';
  final TextEditingController _alasanController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, 
      maxWidth: 800,    
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _kirimFormIzin() async {
    if (_imageFile == null) {
      CustomSnackBar.showError(context, 'Wajib melampirkan foto bukti surat!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        CustomSnackBar.showError(context, 'Sesi Anda telah habis. Silakan login kembali.');
        setState(() => _isLoading = false);
        return;
      }

      var uri = Uri.parse(EndpointApi.ajukanIzin);
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['sesi_id'] = widget.idSesi;
      request.fields['status_kehadiran'] = _statusKehadiran;
      request.fields['keterangan'] = _alasanController.text;

      var multipartFile = await http.MultipartFile.fromPath(
        'foto_bukti', 
        _imageFile!.path
      );
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        if (!mounted) return;
        CustomSnackBar.showSuccess(context, 'Pengajuan $_statusKehadiran Berhasil Dikirim!');
        Navigator.pop(context); 
      } else {
        if (!mounted) return;
        print("ERROR API: ${response.body}"); 
        CustomSnackBar.showError(context, 'Gagal mengirim permohonan ke server. (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.showError(context, 'Terjadi kesalahan koneksi: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Form Izin & Sakit",
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Mata Kuliah: ${widget.namaMatkul}",
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomDropdownField(
              label: "Pilih Jenis Pengajuan",
              value: _statusKehadiran,
              items: const ['Sakit', 'Izin'],
              onChanged: (value) {
                setState(() {
                  _statusKehadiran = value!;
                });
              },
            ),

            const SizedBox(height: 24),
            Text(
              _statusKehadiran == 'Sakit' ? "Keterangan Tambahan (Opsional)" : "Alasan Izin (Wajib Diisi)",
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _alasanController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: _statusKehadiran == 'Sakit'
                    ? "Contoh: Demam tinggi sejak tadi malam..."
                    : "Jelaskan alasan izin Anda secara mendetail...",
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Text(
              _statusKehadiran == 'Sakit' ? "Foto Surat Keterangan Sakit" : "Foto Bukti Pendukung",
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            GestureDetector(
              onTap: _isLoading ? null : _pickImageFromCamera,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_enhance_rounded, size: 36, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              "Ketuk untuk Ambil Foto",
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _kirimFormIzin,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Kirim Pengajuan",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}