import 'package:flutter/material.dart';

void main() {
  runApp(const VoucherMasterApp());
}

class VoucherMasterApp extends StatelessWidget {
  const VoucherMasterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voucher Master',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blueAccent,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SVIPScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' WiFi အမည်ရိုက်ထည့်ပါ(Pro Edition)'),
        backgroundColor: const Color(0xFF0080FF),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E2C),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.security), label: 'SVIP'),
        ],
      ),
    );
  }
}

// HOME SCREEN
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _showPrintDialog(BuildContext context) {
    TextEditingController countController = TextEditingController(text: '33');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('Print', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How many cards? (Custom)', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF121212),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              String count = countController.text;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Printer01 သို့ ချိတ်ဆက်၍ ကဒ် $count ခုကို ပုံနှိပ်နေပါပြီ...')),
              );
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          color: const Color(0xFF1E1E2C),
          child: ListTile(
            leading: const Icon(Icons.note_alt, color: Colors.blue),
            title: const Text('Voucher Manager'),
            subtitle: const Text('မသုံးရသေးသော ကဒ်များ (Total:  )[span_0](start_span)[span_0](end_span)'),
            trailing: IconButton(
              icon: const Icon(Icons.print, color: Colors.white),
              onPressed: () => _showPrintDialog(context),
            ),
          ),
        ),
        Card(
          color: const Color(0xFF1E1E2C),
          child: ListTile(
            leading: const Icon(Icons.devices, color: Colors.green),
            title: const Text('Connected Devices'),
            subtitle: const Text('ချိတ်ဆက်ထားသော ဖုန်းများ ကြည့်ရန် (Active:   )[span_ ](start_span)[span_ ](end_span)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connected Devices မျက်နှာပြင်သို့ ရောက်ရှိပါပြီ')),
              );
            },
          ),
        ),
        Card(
          color: const Color(0xFF1E1E2C),
          child: ListTile(
            leading: const Icon(Icons.analytics, color: Colors.orange),
            title: const Text('Revenue'),
            subtitle: const Text('တစ်နေ့တာ ဝင်ငွေစာရင်း (      Ks)[span_ ](start_span)[span_ ](end_span)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Revenue စာရင်းများကို ပြသနေပါပြီ')),
              );
            },
          ),
        ),
      ],
    );
  }
}

// SVIP SCREEN
class SVIPScreen extends StatelessWidget {
  const SVIPScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          color: const Color(0xFF1E1E2C),
          child: ListTile(
            leading: const Icon(Icons.block, color: Colors.redAccent),
            title: const Text('Block Hotspot (FREE)'),
            subtitle: const Text('TTL rule ဖြင့် Hotspot sharing ကို ကာကွယ်ရန်[span_ ](start_span)[span_ ](end_span)'),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('TTL Hotspot Block အောင်မြင်ပါသည်')),
                );
              },
              child: const Text('Run'),
            ),
          ),
        ),
        Card(
          color: const Color(0xFF1E1E2C),
          child: ListTile(
            leading: const Icon(Icons.router, color: Colors.blueAccent),
            title: const Text('Starlink Reboot Fix'),
            subtitle: const Text('Starlink Shutdown ပြဿနာကို ဖြေရှင်းရန်[span_ ](start_span)[span_ ](end_span)'),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starlink Fix အောင်မြင်ပါသည်')),
                );
              },
              child: const Text('Run'),
            ),
          ),
        ),
      ],
    );
  }
}
