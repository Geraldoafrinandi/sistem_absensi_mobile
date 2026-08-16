import 'package:flutter/material.dart';

class ScheduleModel {
  final int? idJadwal;
  final String subject;
  final String time;
  final String lecturer;
  final String room;
  final String status;
  final Color statusColor;

  final bool isSessionActive;
  final int? sesiId;
  final double? latitudeDosen;
  final double? longitudeDosen;
  final int? radiusIzin;

  ScheduleModel({
    this.idJadwal,
    required this.subject,
    required this.time,
    required this.lecturer,
    required this.room,
    required this.status,
    required this.statusColor,
    this.isSessionActive = false,
    this.sesiId,
    this.latitudeDosen,
    this.longitudeDosen,
    this.radiusIzin,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    String rawStatus = json['status_sesi'] ?? "Belum Mulai";
    bool sessionOpen = json['isSessionOpen'] ?? false;

    String currentStatus;
    Color currentColor;

    if (rawStatus == "Tutup") {
      currentStatus = "Tutup";
      currentColor = Colors.red;
    } else if (sessionOpen) {
      currentStatus = "Sesi Buka";
      currentColor = const Color(0xFF22C55E);
    } else {
      currentStatus = "Belum Mulai";
      currentColor = const Color(0xFFF97316);
    }

    return ScheduleModel(
      idJadwal: json['id'] ?? json['id_jadwal'] ?? json['jadwal_id'],
      subject: json['subject'] ?? "Tidak ada mata kuliah",
      time: json['time'] ?? "-",
      lecturer: json['lecturer'] ?? "Tidak ada dosen",
      room: json['room'] ?? "Tidak ada ruangan",
      status: currentStatus,
      statusColor: currentColor,
      isSessionActive: sessionOpen,
      sesiId: json['id_sesi'] ?? json['sesi_id'] ?? json['sesiId'],
      latitudeDosen: json['latitude_dosen'] != null
          ? double.tryParse(json['latitude_dosen'].toString())
          : null,
      longitudeDosen: json['longitude_dosen'] != null
          ? double.tryParse(json['longitude_dosen'].toString())
          : null,
      radiusIzin: json['radius_izin_meter'] != null
          ? int.tryParse(json['radius_izin_meter'].toString())
          : null,
    );
  }
}
