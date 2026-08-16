import 'package:geolocator/geolocator.dart';

class AttendanceController {
  Future<Map<String, dynamic>> processAttendanceData({
    required int sesiId, 
  }) async {
    
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation, 
      timeLimit: const Duration(seconds: 10), 
    );

    return {
      "sesi_id": sesiId,
      "latitude_mahasiswa": position.latitude,
      "longitude_mahasiswa": position.longitude,
    };
  }
}