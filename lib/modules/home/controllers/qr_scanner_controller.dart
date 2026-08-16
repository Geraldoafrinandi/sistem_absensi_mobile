import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
  import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:frontend_mahasiswa/core/data/global_data.dart';
import 'package:frontend_mahasiswa/core/ui/widgets/attendance_status_dialog.dart';
import 'package:frontend_mahasiswa/core/services/storage_service.dart';
import 'package:frontend_mahasiswa/core/data/endpoint_api.dart';

class QrScannerController {
  static Future<void> processScannedQR({
    required BuildContext context,
    required String scannedToken,
  }) async {
    bool isDialogLoadingOpen = true;
    _showLoading(context, "Memproses Presensi...");

    final client = http.Client();

    try {
      final userToken = await StorageService.getToken() ?? "";

      if (userToken.isEmpty) {
        throw "Token tidak ditemukan. Silakan login kembali.";
      }

      bool isExpired = JwtDecoder.isExpired(userToken);
      if (isExpired) {
        
        await StorageService.clearAuthData(); 
        throw "Sesi login Anda telah berakhir.";
      }

      if (!GlobalData.isGpsReady.value) {
        try {
          Position fallbackPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            timeLimit: const Duration(seconds: 4),
          );
          GlobalData.updatePosition(fallbackPosition);
        } catch (e) {
          throw "Sinyal GPS sangat lemah. Cobalah mendekat ke jendela kelas agar mendapat sinyal satelit.";
        }
      }

      final latitude = GlobalData.latitude!;
      final longitude = GlobalData.longitude!;
      final accuracy = GlobalData.accuracy!;

      final verifyResponse = await client
          .post(
            Uri.parse(EndpointApi.verifyQr),
            headers: {
              "Authorization": "Bearer $userToken",
              "Content-Type": "application/json",
            },
            body: json.encode({"token": scannedToken}),
          )
          .timeout(const Duration(seconds: 5));

      final verifyResult = json.decode(verifyResponse.body);
      if (verifyResponse.statusCode == 401) {
        await StorageService.clearAuthData(); 
        throw "Sesi ditolak oleh server. Silakan login ulang.";
      } else if (verifyResponse.statusCode != 200) {
        throw verifyResult['message'] ?? "QR Tidak Valid";
      }

      final sesiData = verifyResult['data'];

      final submitResponse = await client
          .post(
            Uri.parse(EndpointApi.submitAbsen),
            headers: {
              "Authorization": "Bearer $userToken",
              "Content-Type": "application/json",
            },
            body: json.encode({
              "sesi_id": sesiData['id_sesi'],
              "latitude_mahasiswa": latitude,
              "longitude_mahasiswa": longitude,
              "akurasi_mahasiswa": accuracy,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (context.mounted && isDialogLoadingOpen) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogLoadingOpen = false;
      }

      final responseData = json.decode(submitResponse.body);

      if (submitResponse.statusCode == 401) {
         await StorageService.clearAuthData();
         throw "Sesi ditolak oleh server saat menyimpan absen. Silakan login ulang.";
      }

      if (submitResponse.statusCode == 201) {
        final absenData = responseData['data'];

        final double jarakServer = absenData['jarak_vincenty'] != null
            ? double.parse(absenData['jarak_vincenty'].toString())
            : 0.0;
        final String statusKehadiran = absenData['status_kehadiran'] ?? "Hadir";

        final String pesanKeterangan =
            responseData['message'] ?? "Presensi Berhasil!";

        if (context.mounted) {
          AttendanceStatusDialog.show(
            context,
            isSuccess:
                statusKehadiran == "Hadir" || statusKehadiran == "Terlambat",

            message: statusKehadiran == "Hadir"
                ? "Presensi Berhasil!"
                : "Anda Terlambat!",

            subMessage:
                "$pesanKeterangan\nJarak ke Dosen: ${jarakServer.toStringAsFixed(1)}m",
          );
        }
      }
    } on TimeoutException {
      _handleError(context, "Koneksi lambat. Coba lagi!", isDialogLoadingOpen);
    } on SocketException {
      _handleError(
        context,
        "Tidak dapat menjangkau server. Cek internet!",
        isDialogLoadingOpen,
      );
    } catch (e) {
      _handleError(context, e.toString(), isDialogLoadingOpen);
    } finally {
      client.close();
    }
  }

  static void _handleError(BuildContext context, String message, bool isOpen) {
    if (isOpen && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (context.mounted) {
      AttendanceStatusDialog.show(
        context,
        isSuccess: false,
        message: "Presensi Gagal",
        subMessage: message.replaceAll("Exception: ", ""),
      );
    }
  }

  static void _showLoading(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(message, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
