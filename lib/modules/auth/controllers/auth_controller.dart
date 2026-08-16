import 'dart:convert';
import 'package:frontend_mahasiswa/core/data/endpoint_api.dart';
import 'package:frontend_mahasiswa/core/services/device_helper.dart';
import 'package:frontend_mahasiswa/core/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthController {

  Future<bool> isUserLoggedInAndValid() async {
    try {
      final token = await StorageService.getToken();

      if (token == null || token.isEmpty) {
        return false; 
      }

     
      bool isExpired = JwtDecoder.isExpired(token);

      if (isExpired) {
        await StorageService.clearAuthData();
        return false;
      }

      return true;
    } catch (e) {
      print("Error checking token: $e");
      return false;
    }
  }

  Future<String?> login(String nim, String password) async {
    try {
      final String deviceId = await DeviceHelper.getUniqueDeviceId();
      final url = Uri.parse(EndpointApi.login);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nim': nim,
          'password': password,
          'device_id': deviceId,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final data = responseData['data'];

        await StorageService.saveAuthData(
          token: responseData['token'],
          nim: data['nim'].toString(),
          namaUser: data['nama_user'].toString(),
          namaKelas: data['nama_kelas'].toString(),
          tahunAngkatan: data['tahun_angkatan']?.toString() ?? "-",
          email: data['email']?.toString() ?? "-",
          telepon: data['telepon']?.toString() ?? "-",
        );

        return null;
      } else {
        return responseData['message'] ?? "Gagal login";
      }
    } catch (e) {
      print("DEBUG ERROR: $e");
      return "Terjadi kesalahan server/jaringan: $e";
    }
  }

  Future<bool> logout() async {
    try {
      final url = Uri.parse(EndpointApi.logout);
      await http.post(url);

      await StorageService.clearAuthData();

      return true;
    } catch (e) {
      print("Error Logout: $e");
      return false;
    }
  }
}
