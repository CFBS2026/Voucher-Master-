import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'services/printer_service.dart';

class PrintSettingScreen extends StatefulWidget {
  const PrintSettingScreen({Key? key}) : super(key: key);

  @override
  _PrintSettingScreenState createState() => _PrintSettingScreenState();
}

class _PrintSettingScreenState extends State<PrintSettingScreen> {
  final PrinterService _printerService = PrinterService();
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() async {
    List<BluetoothDevice> devices = await _printerService.getPairedDevices();
    setState(() {
      _devices = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Printer Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<BluetoothDevice>(
              value: _selectedDevice,
              hint: const Text("Select Bluetooth Thermal Printer"),
              isExpanded: true,
              items: _devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device.name ?? "Unknown Device"),
                );
              }).toList(),
              onChanged: (device) {
                setState(() {
                  _selectedDevice = device;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedDevice == null
                  ? null
                  : () async {
                      if (_isConnected) {
                        await _printerService.disconnect();
                        setState(() => _isConnected = false);
                      } else {
                        bool res = await _printerService.connect(_selectedDevice!);
                        setState(() => _isConnected = res);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_isConnected ? "Printer Connected Successfully" : "Connection Failed")),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: Text(_isConnected ? "Disconnect Printer" : "Connect Printer"),
            ),
          ],
        ),
      ),
    );
  }
}
