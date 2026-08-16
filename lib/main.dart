import 'package:flutter/material.dart';
import 'package:frontend_mahasiswa/core/routes/app_routes.dart';
import 'package:frontend_mahasiswa/core/services/storage_service.dart';
import 'package:frontend_mahasiswa/modules/auth/controllers/auth_controller.dart';
import 'package:frontend_mahasiswa/modules/auth/login_pages.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final authController = AuthController();
  final bool isTokenValid = await authController.isUserLoggedInAndValid();
    final String startRoute = isTokenValid ? AppRoutes.main : AppRoutes.login;

  runApp(MyApp(initialRoute: startRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute; 
  
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      
      initialRoute: initialRoute, 
      routes: AppRoutes.routes,
    );
  }
}