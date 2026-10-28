import 'package:flutter/material.dart';
import 'screens/voucher_generator_screen.dart';
import 'screens/printer_screen.dart';
import 'screens/history_screen.dart';
import 'services/printer_service.dart';

void main() {
  runApp(const VoucherMasterApp());
}

class VoucherMasterApp extends StatelessWidget {
  const VoucherMasterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voucher Master',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final PrinterService _printerService = PrinterService();

  @override
  Widget build(BuildContext context) {
    final screens = [
      VoucherGeneratorScreen(printerService: _printerService),
      PrinterScreen(printerService: _printerService),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Generate"),
          BottomNavigationBarItem(icon: Icon(Icons.print), label: "Printer"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}
