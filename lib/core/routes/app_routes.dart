import 'package:flutter/material.dart';
import 'package:frontend_mahasiswa/modules/auth/login_pages.dart';
import 'package:frontend_mahasiswa/core/ui/layout/main_layout.dart';

class AppRoutes {
  static const String login = '/login';
  static const String main = '/main';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPages(),
    main: (context) => const MainLayout(),
  };
}