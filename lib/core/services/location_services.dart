import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../data/global_data.dart';

class LocationService {
  static StreamSubscription<Position>? _subscription;
  static Timer? _autoRefreshTimer;

  static Future<void> startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("GPS belum aktif");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Izin lokasi ditolak permanen");
    }

    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      GlobalData.updatePosition(initialPosition);

      print("=== FAST-TRACK POSISI ===");
      print(
        "Lat: ${initialPosition.latitude}, Long: ${initialPosition.longitude}",
      );
      print("Akurasi Awal: ${initialPosition.accuracy} meter");
    } catch (e) {
      print("Fast-track gagal: $e");
    }

    await _subscription?.cancel();
    _subscription =
        Geolocator.getPositionStream(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 20,
            forceLocationManager: false,
            intervalDuration: Duration(seconds: 2),
          ),
        ).listen((position) {
          GlobalData.currentPosition = position;
          GlobalData.latitude = position.latitude;
          GlobalData.longitude = position.longitude;
          GlobalData.accuracy = position.accuracy;

          if (position.accuracy <= 20) {
            print("AKURAT: ${position.accuracy}m. Status: READY.");
            GlobalData.isGpsReady.value = true;
          } else {
            print(
              "MENCARI... (Akurasi saat ini: ${position.accuracy.toStringAsFixed(1)}m)",
            );
            GlobalData.isGpsReady.value = false;
          }
        });
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!GlobalData.isGpsReady.value) {
        print("Sinyal belum stabil, memaksa penyegaran koneksi GPS...");
        startTracking();
      } else {
        timer.cancel();
      }
    });
  }

  static Future<void> stopTracking() async {
    await _subscription?.cancel();
    _autoRefreshTimer?.cancel();
    GlobalData.clearPosition();
  }
}
