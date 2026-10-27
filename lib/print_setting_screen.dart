
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrintSettingScreen extends StatefulWidget {
  const PrintSettingScreen({super.key});

  @override
  State<PrintSettingScreen> createState() =>
      _PrintSettingScreenState();
}

class _PrintSettingScreenState extends State<PrintSettingScreen> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final TextEditingController _wifiController =
      TextEditingController(text: 'Voucher Master WiFi');

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _connected = false;
  bool _loading = false;
  int _selectedStyle = 2;

  @override
  void initState() {
    super.initState();
    _loadBluetooth();
  }

  Future<void> _loadBluetooth() async {
    if (mounted) {
      setState(() => _loading = true);
    }

    try {
      final devices = await bluetooth.getBondedDevices();
      final connected = await bluetooth.isConnected;

      if (!mounted) return;

      setState(() {
        _devices = devices;
        _connected = connected ?? false;
      });
    } catch (e) {
      if (mounted) {
        _showMessage(
          'Printer စာရင်းရယူ၍ မရပါ။ Bluetooth ခွင့်ပြုချက်ကို စစ်ပါ။',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    try {
      if (_connected) {
        await bluetooth.disconnect();
      }

      await bluetooth.connect(device);
      final connected = await bluetooth.isConnected;

      if (!mounted) return;

      setState(() {
        _selectedDevice = device;
        _connected = connected ?? false;
      });

      _showMessage(
        _connected
            ? 'Printer ချိတ်ဆက်ပြီးပါပြီ။'
            : 'Printer ချိတ်ဆက်မှု မအောင်မြင်ပါ။',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _connected = false);
        _showMessage('Printer ချိတ်ဆက်မှု မအောင်မြင်ပါ။');
      }
    }
  }

  Future<void> _disconnect() async {
    try {
      await bluetooth.disconnect();

      if (!mounted) return;

      setState(() => _connected = false);
      _showMessage('Printer ချိတ်ဆက်မှု ဖြုတ်ပြီးပါပြီ။');
    } catch (e) {
      if (mounted) {
        _showMessage('ချိတ်ဆက်မှု ဖြုတ်၍ မရပါ။');
      }
    }
  }

  Future<void> _testPrint() async {
    if (_selectedDevice == null || !_connected) {
      _showMessage('Printer ကို အရင်ချိတ်ဆက်ပါ။');
      return;
    }

    try {
      final connected = await bluetooth.isConnected;

      if (connected != true) {
        if (mounted) {
          setState(() => _connected = false);
          _showMessage('Printer ချိတ်ဆက်မှု ပြတ်တောက်နေပါသည်။');
        }
        return;
      }

      bluetooth.printNewLine();
      bluetooth.printCustom(_wifiController.text.trim(), 1, 1);
      bluetooth.printNewLine();

      if (_selectedStyle == 1) {
        bluetooth.printCustom('WIFI VOUCHER', 1, 1);
        bluetooth.printCustom('VF-TEST1234', 2, 1);
      } else {
        bluetooth.printCustom('--- WIFI VOUCHER ---', 1, 1);
        bluetooth.printCustom('VF-TEST1234', 3, 1);
      }

      bluetooth.printCustom('Price: 1000 Ks', 1, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.paperCut();

      _showMessage('စမ်းသပ်ပုံနှိပ်မှု ပို့ပြီးပါပြီ။');
    } catch (e) {
      _showMessage('ပုံနှိပ်၍ မရပါ။ Printer ကို စစ်ဆေးပါ။');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _wifiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Print Setting'),
        backgroundColor: const Color(0xFF2A2A40),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'PRINTER SETTINGS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),

          TextField(
            controller: _wifiController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Wi-Fi အမည်',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(
                Icons.wifi,
                color: Colors.blueAccent,
              ),
              filled: true,
              fillColor: const Color(0xFF2A2A40),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bluetooth Printer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_devices.isEmpty)
                  const Text(
                    'ချိတ်ဆက်ထားသော Bluetooth Printer မတွေ့ပါ။',
                    style: TextStyle(color: Colors.white70),
                  )
                else
                  DropdownButtonFormField<BluetoothDevice>(
                    value: _selectedDevice,
                    dropdownColor: const Color(0xFF2A2A40),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Printer ရွေးချယ်ရန်',
                      border: OutlineInputBorder(),
                    ),
                    items: _devices.map((device) {
                      return DropdownMenuItem<BluetoothDevice>(
                        value: device,
                        child: Text(
                          device.name ?? 'Unknown Printer',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (device) {
                      if (device != null) {
                        _connect(device);
                      }
                    },
                  ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      _connected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      color: _connected ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _connected
                            ? 'Printer ချိတ်ဆက်ထားသည်'
                            : 'Printer မချိတ်ဆက်ရသေးပါ',
                        style: TextStyle(
                          color: _connected
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _loadBluetooth,
                        icon: const Icon(Icons.refresh),
                        label: const Text('ပြန်ရှာရန်'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_connected)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _disconnect,
                          icon: const Icon(Icons.link_off),
                          label: const Text('ဖြုတ်ရန်'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'စလစ်ပုံစံ ရွေးချယ်ရန်',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          RadioListTile<int>(
            value: 1,
            groupValue: _selectedStyle,
            activeColor: Colors.blueAccent,
            title: const Text(
              'ရိုးရှင်းသောပုံစံ',
              style: TextStyle(color: Colors.white),
            ),
            onChanged: (value) {
              setState(() => _selectedStyle = value!);
            },
          ),

          RadioListTile<int>(
            value: 2,
            groupValue: _selectedStyle,
            activeColor: Colors.blueAccent,
            title: const Text(
              'အကြီးစား Voucher Code ပုံစံ',
              style: TextStyle(color: Colors.white),
            ),
            onChanged: (value) {
              setState(() => _selectedStyle = value!);
            },
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _wifiController.text.isEmpty
                      ? 'Voucher Master WiFi'
                      : _wifiController.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.black),
                const Text(
                  'WIFI VOUCHER',
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 8),
                const Text(
                  'TEST1234',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Price: 1000 Ks',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _testPrint,
              icon: const Icon(Icons.print),
              label: const Text(
                'Test Print',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'မှတ်ချက် - TEST1234 သည် စမ်းသပ်ကုဒ်သာဖြစ်ပြီး '
            'Ruijie Gateway မှ ထုတ်ပေးသော Voucher အစစ်မဟုတ်ပါ။',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
