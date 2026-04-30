import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_pilot/data/services/hive_service.dart';
import 'package:spend_pilot/modules/tracker/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive singleton
  await HiveService.instance.init();

  runApp(const ProviderScope(child: SpendPilotApp()));
}

class SpendPilotApp extends StatelessWidget {
  const SpendPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spend Pilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0066FF)),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}