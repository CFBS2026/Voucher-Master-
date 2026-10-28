import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'printer_service.dart';

class PrintSettingScreen extends StatefulWidget {
  const PrintSettingScreen({Key? key}) : super(key: key);

  @override
  _PrintSettingScreenState createState() => _PrintSettingScreenState();
}

class _PrintSettingScreenState extends State<PrintSettingScreen> {
  final PrinterService _printerService = PrinterService();
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  void _initBluetooth() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } catch (e) {
      print("Error getting bonded devices: $e");
    }

    setState(() {
      _isConnected = isConnected ?? false;
      _devices = devices;
    });
  }

  void _connect(BluetoothDevice device) async {
    if (_selectedDevice != null) {
      bluetooth.connect(device).catchError((error) {
        setState(() => _isConnected = false);
      });
      setState(() {
        _selectedDevice = device;
        _isConnected = true;
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _isConnected = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Printer Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isConnected ? "Status: Connected" : "Status: Disconnected",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButton<BluetoothDevice>(
              isExpanded: true,
              hint: const Text("Select Bluetooth Printer"),
              value: _selectedDevice,
              items: _devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device.name ?? "Unknown Device"),
                );
              }).toList(),
              onChanged: (device) => setState(() => _selectedDevice = device),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _selectedDevice != null ? () => _connect(_selectedDevice!) : null,
                  child: const Text("Connect"),
                ),
                ElevatedButton(
                  onPressed: _isConnected ? _disconnect : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Disconnect"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
