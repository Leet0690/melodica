import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/hive_service.dart';
import 'services/melody_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => MelodyProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melodica',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
