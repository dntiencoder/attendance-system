import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app.dart';            // ← import MyApp
import 'dev/demo_seeder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Chạy Seeder mỗi lần khởi động
  await DemoSeeder.cleanAndSeed();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}