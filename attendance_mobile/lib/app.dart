import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance App'),
        ),
        body: const Center(
          child: Text('Firebase Connected'),
        ),
      ),
    );
  }
}