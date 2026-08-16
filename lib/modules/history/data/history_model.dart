import 'package:flutter/material.dart';

class HistoryModel {
  final String subject;
  final String time;
  final String lecturer;
  final String statusDetail;
  final String statusType;
  final String room;
  final String date;
  final String keterangan;

  HistoryModel({
    required this.subject,
    required this.time,
    required this.lecturer,
    required this.statusDetail,
    required this.statusType,
    required this.room,
    required this.date,
    required this.keterangan,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      subject: json['subject'] ?? '-',
      time: json['time'] ?? '-',
      lecturer: json['lecturer'] ?? '-',
      statusDetail: json['statusDetail'] ?? '-',
      statusType: json['statusType'] ?? '-',
      room: json['room'] ?? '-',
      date: json['date'] ?? '-',
      keterangan: json['keterangan'] ?? '',
    );
  }

  String get displayStatus {
    if (statusType.toLowerCase() == 'terlambat' && keterangan.isNotEmpty) {
      return keterangan; 
    }

    return statusDetail;
  }

  Color get themeColor {
    switch (statusType.toLowerCase()) {
      case 'hadir':
        return const Color(0xFF10B981);
      case 'terlambat':
        return const Color(0xFFF59E0B);
      case 'alpa':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF3B82F6);
    }
  }
}
