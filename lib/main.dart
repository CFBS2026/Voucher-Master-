
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'activation_screen.dart';
import 'home_screen.dart';
import 'print_setting_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VoucherMasterApp());
}

class VoucherMasterApp extends StatelessWidget {
  const VoucherMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voucher Master',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
        primaryColor: const Color(0xFF193B63),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF193B63),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A2A40),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const StartupScreen(),
      routes: {
        '/activation': (context) => const ActivationScreen(),
        '/home': (context) => const HomeScreen(),
        '/print_setting': (context) => const PrintSettingScreen(),
      },
    );
  }
}

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  Future<bool> _checkActivation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isActivated') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkActivation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const ActivationScreen();
        }

        if (snapshot.data == true) {
          return const HomeScreen();
        }

        return const ActivationScreen();
      },
    );
  }
}
