import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'app.dart';

/// FEAT-05 — entrypoint CHỈ dùng để kiểm thử Firestore Rules cục bộ trên
/// Firebase Emulator (Phase 19), KHÔNG chạm dữ liệu Production. Trước khi
/// chạy file này, khởi động emulator ở thư mục gốc repo:
///
///   firebase emulators:start --only firestore,auth
///
/// rồi: `flutter run -t lib/main_emulator.dart`. Xem
/// docs/implementation/FEAT_05_IMPLEMENTATION_PLAN.md Phase 17/19.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
