import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/attendance/presentation/gps_test_screen.dart';
import 'features/attendance/presentation/checkin_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Attendance App',
        home: const CheckInScreen(),
      ),
    );
  }
}