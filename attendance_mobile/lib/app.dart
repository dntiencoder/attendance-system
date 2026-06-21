import 'package:flutter/material.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'shared/theme/app_theme.dart'; // ← thêm

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App',
      theme: AppTheme.lightTheme, // ← dùng AppTheme
      home: const AuthGate(),
    );
  }
}