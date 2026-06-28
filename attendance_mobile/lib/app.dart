import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'shared/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
