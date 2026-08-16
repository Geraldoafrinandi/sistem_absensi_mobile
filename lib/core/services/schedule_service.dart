import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/endpoint_api.dart';
import 'storage_service.dart';
import '../../modules/schedule/data/course_schedule_model.dart';

class ScheduleService {
  static Future<List<CourseScheduleModel>> getMySchedules() async {
    try {
      final token = await StorageService.getToken();
      final response = await http.get(
        Uri.parse("${EndpointApi.baseUrl}/mahasiswa/jadwal"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => CourseScheduleModel.fromJson(item)).toList();
      } else {
        throw Exception("Gagal mengambil jadwal");
      }
    } catch (e) {
      rethrow;
    }
  }
}