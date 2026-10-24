import 'package:flutter/material.dart';

import 'app_services.dart';
import 'theme/app_theme.dart';
import 'view/home_screen.dart';
import 'view/session_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FocusFlowApp(services: AppServices.create()));
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key, this.services});

  // The no-database route preserves the existing timer widget test.
  final AppServices? services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: services == null
          ? const SessionScreen()
          : HomeScreen(services: services!),
    );
  }
}
