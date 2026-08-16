import 'package:flutter/material.dart';

class CourseScheduleModel {
  final int id;
  final String hari;
  final String startTime;
  final String endTime;
  final String subject;
  final String lecturer;
  final String room;
  final String className;
  final int sks;

  CourseScheduleModel({
    required this.id,
    required this.hari,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.lecturer,
    required this.room,
    required this.className,
    required this.sks,
  });

  Color get themeColor {
    if (sks <= 2) {
      return const Color(0xFF10B981); 
    } else if (sks == 3) {
      return const Color(0xFF3B82F6); 
    } else {
      return const Color(0xFFE11D48);
    }
  }

  Color get badgeColor {
    if (sks <= 2) {
      return const Color(0xFFD1FAE5); 
    } else if (sks == 3) {
      return const Color(0xFFDBEAFE); 
    } else {
      return const Color(0xFFFFE4E6); 
    }
  }

  factory CourseScheduleModel.fromJson(Map<String, dynamic> json) {
    List<String> timeParts = json['time'].split(' - ');

    return CourseScheduleModel(
      id: json['id'], 
      hari: json['hari'] ?? "-", 
      startTime: timeParts[0], 
      endTime: timeParts[0], 
      subject: json['subject'], 
      lecturer: json['lecturer'], 
      room: json['room'], 
      className: json['class'], 
      sks: json['sks']
      );
  }
}