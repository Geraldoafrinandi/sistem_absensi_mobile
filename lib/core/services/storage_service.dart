import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'token';
  static const String _nimKey = 'nim';
  static const String _namaKey = 'nama_user';
  static const String _kelasKey = 'nama_kelas';
  static const String _keyAngkatan = 'tahun_angkatan';
  static const String _keyEmail = 'email';
  static const String _keyTelepon = 'telepon';
  static const String _keyLastActive = "last_active_time";

  

  // Ambil token untuk otentikasi
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Ambil data nama mhs
  static Future<String?> getNamaKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_namaKey);
  }

  // Ambil data nim mhs
  static Future<String?> getNim() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nimKey);
  }

  // Ambil data nama kelas mhs
  static Future<String?> getNamaKelas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kelasKey);
  }

  // Ambil data thun angkatan mhs
  static Future<String?> getTahunAngkatan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAngkatan);
  }

  // Ambil data email mhs
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  // Ambil data nohp mhs
  static Future<String?> getTelepon() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTelepon);
  }

  // Hapus data login
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_nimKey);
    await prefs.remove(_namaKey);
    await prefs.remove(_kelasKey);
    await prefs.remove(_keyAngkatan);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyTelepon);
  }

  // Simpan waktu terakhir aktif
  static Future<void> saveLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastActive, DateTime.now().toIso8601String());
  }

  // Ambil waktu terakhir aktif
  static Future<DateTime?> getLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_keyLastActive);
    if (timeStr == null) return null;
    return DateTime.parse(timeStr);
  }

  // Hapus waktu terakhir aktif
  static Future<void> removeLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastActive);
  }

  // Simpan data saat login
  static Future<void> saveAuthData({
    required String token,
    required String nim,
    required String namaUser,
    required String namaKelas,
    String? tahunAngkatan,
    String? email,
    String? telepon,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_nimKey, nim);
    await prefs.setString(_namaKey, namaUser);
    await prefs.setString(_kelasKey, namaKelas);

    await prefs.setString(_keyAngkatan, tahunAngkatan ?? "-");
    await prefs.setString(_keyEmail, email ?? "-");
    await prefs.setString(_keyTelepon, telepon ?? "-");
  }
}
