import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const CompulsaApp());
}

class CompulsaApp extends StatelessWidget {
  const CompulsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compulsa - Asistente Tributario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // Usar tema claro también para el modo oscuro
      themeMode: ThemeMode.light, // Forzar siempre el tema claro
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
