import 'package:flutter/material.dart';
import 'activation_screen.dart';
import 'home_screen.dart';
import 'print_setting_screen.dart';

void main() {
  runApp(const VoucherMasterApp());
}

class VoucherMasterApp extends StatelessWidget {
  const VoucherMasterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voucher Master',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ActivationScreen(),
        '/home': (context) => HomeScreen(),
        '/print_setting': (context) => PrintSettingScreen(),
      },
    );
  }
}
