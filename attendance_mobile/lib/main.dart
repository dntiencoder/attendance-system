import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dev/create_test_user.dart';
import 'firebase_options.dart';
import 'app.dart'; // ← import MyApp

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await CreateTestUser.createEmployee();

  runApp(const MyApp());
}