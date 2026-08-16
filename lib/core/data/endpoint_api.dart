class EndpointApi {
  // static const String baseUrl = 'http://192.168.18.6:5000/api/mobile';
  // static const String baseUrl = 'http://10.205.109.156:5000/api/mobile';
  static const String baseUrl = 'https://api.geraldosite.my.id/api/mobile';


  static const String login = '$baseUrl/login-mahasiswa';
  static const String logout = '$baseUrl/logout-mahasiswa';

  static const String jadwalMahasiswa = '$baseUrl/jadwal-mahasiswa';

  static const String verifyQr = '$baseUrl/absensi/verify-qr';
  static const String submitAbsen = '$baseUrl/absensi/submit';

  static const String ajukanIzin = '$baseUrl/absensi/izin';
  
  static const String riwayatAbsensi = "$baseUrl/mahasiswa/riwayat";
  static const String statistikMingguan = "$baseUrl/mahasiswa/statistik-mingguan";
  static const String statistikProfil = "$baseUrl/mahasiswa/profile-stats";
}
