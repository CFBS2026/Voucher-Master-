import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color backgroundColor = Color(0xFF1E1E2C);
  static const Color cardColor = Color(0xFF2A2A40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Voucher Master',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: cardColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1E5631),
                      Color(0xFF123B28),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.wifi,
                      color: Colors.white,
                      size: 42,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Voucher Master',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Ruijie Gateway Voucher Management',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'MAIN MENU',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              _menuCard(
                context,
                icon: Icons.confirmation_number,
                title: 'Voucher Management',
                subtitle: 'Voucher Code များ ထုတ်ယူရန်',
                iconColor: Colors.orangeAccent,
                onTap: () {
                  _showMessage(
                    context,
                    'Voucher Management ကို ဆက်လက်တည်ဆောက်ရန် လိုအပ်ပါသည်။',
                  );
                },
              ),

              _menuCard(
                context,
                icon: Icons.print,
                title: 'Print Setting',
                subtitle: 'Bluetooth Printer နှင့် စလစ်ပုံစံ',
                iconColor: Colors.blueAccent,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/print_setting',
                  );
                },
              ),

              _menuCard(
                context,
                icon: Icons.people,
                title: 'Customer Management',
                subtitle: 'Customer များ စီမံခန့်ခွဲရန်',
                iconColor: Colors.cyanAccent,
                onTap: () {
                  _showMessage(
                    context,
                    'Customer Management ကို ဆက်လက်တည်ဆောက်ရန် လိုအပ်ပါသည်။',
                  );
                },
              ),

              _menuCard(
                context,
                icon: Icons.bar_chart,
                title: 'Voucher Reports',
                subtitle: 'Voucher ထုတ်ယူမှု မှတ်တမ်းများ',
                iconColor: Colors.purpleAccent,
                onTap: () {
                  _showMessage(
                    context,
                    'Voucher Reports ကို ဆက်လက်တည်ဆောက်ရန် လိုအပ်ပါသည်။',
                  );
                },
              ),

              _menuCard(
                context,
                icon: Icons.verified_user,
                title: 'License Information',
                subtitle: 'Activation အချက်အလက်များ',
                iconColor: Colors.greenAccent,
                onTap: () {
                  Navigator.pushNamed(context, '/license');
                },
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Voucher Master • Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 25,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white60,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}