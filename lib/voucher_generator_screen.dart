import 'package:flutter/material.dart';
import '../services/ruijie_api_service.dart';
import '../services/printer_service.dart';
import '../services/database_helper.dart';
import '../models/voucher_model.dart';

class VoucherGeneratorScreen extends StatefulWidget {
  final PrinterService printerService;
  const VoucherGeneratorScreen({Key? key, required this.printerService}) : super(key: key);

  @override
  _VoucherGeneratorScreenState createState() => _VoucherGeneratorScreenState();
}

class _VoucherGeneratorScreenState extends State<VoucherGeneratorScreen> {
  final _ipController = TextEditingController(text: "192.168.110.1");
  final _userController = TextEditingController(text: "admin");
  final _passController = TextEditingController(text: "admin");

  String _selectedProfile = "1 Hour - 500 Ks";
  double _profilePrice = 500;
  int _voucherCount = 1;
  bool _isLoading = false;

  void _generateAndPrint() async {
    setState(() => _isLoading = true);

    RuijieApiService api = RuijieApiService(
      gatewayIp: _ipController.text,
      username: _userController.text,
      password: _passController.text,
    );

    bool loggedIn = await api.login();
    if (!loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gateway Login Failed! Check IP/Password")),
      );
      setState(() => _isLoading = false);
      return;
    }

    List<String> codes = await api.generateVouchers(
      profileId: _selectedProfile,
      count: _voucherCount,
    );

    for (String code in codes) {
      // Database ထဲ သိမ်းမည်
      Voucher voucher = Voucher(
        code: code,
        profileName: _selectedProfile,
        price: _profilePrice,
        generatedAt: DateTime.now().toString(),
      );
      await DatabaseHelper.instance.insertVoucher(voucher);

      // Printer ဖြင့် ရိုက်ထုတ်မည်
      await widget.printerService.printVoucherSlip(
        wifiName: "Moe Kaung Kin WiFi",
        voucherCode: code,
        profileName: _selectedProfile,
        price: _profilePrice,
      );
    }

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Successfully generated ${_voucherCount} Vouchers!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generate Voucher")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _ipController, decoration: const InputDecoration(labelText: "Gateway IP")),
            TextField(controller: _userController, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedProfile,
              isExpanded: true,
              items: ["1 Hour - 500 Ks", "24 Hour - 1000 Ks", "7 Day - 5000 Ks"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedProfile = val;
                    if (val.contains("500")) _profilePrice = 500;
                    if (val.contains("1000")) _profilePrice = 1000;
                    if (val.contains("5000")) _profilePrice = 5000;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Count: "),
                IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => _voucherCount = _voucherCount > 1 ? _voucherCount - 1 : 1)),
                Text("$_voucherCount", style: const TextStyle(fontSize: 18)),
                IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _voucherCount++)),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateAndPrint,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: _isLoading ? const CircularProgressIndicator() : const Text("GENERATE & PRINT"),
            ),
          ],
        ),
      ),
    );
  }
}
