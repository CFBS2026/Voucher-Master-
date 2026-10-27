Import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrintSettingScreen extends StatefulWidget {
  @override
  _PrintSettingScreenState createState() => _PrintSettingScreenState();
}

class _PrintSettingScreenState extends State<PrintSettingScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _connected = false;
  
  String wifiName = "Voucher Master WiFi";
  int selectedStyle = 2;

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  Future<void> initBluetooth() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      _devices = devices;
      _connected = isConnected ?? false;
    });
  }

  void _connect(BluetoothDevice device) async {
    if (_connected) {
      await bluetooth.disconnect();
    }
    bluetooth.connect(device).catchError((onError) {
      print(onError);
    });
    setState(() {
      _selectedDevice = device;
      _connected = true;
    });
  }

  // WiFi name နဲ့ ငွေပမာဏ Font ညီပြီး Code ကို ကြီးထားသော စလစ်ရိုက်နည်း
  void printVoucherSlip(String voucherCode, String profilePrice) async {
    if (_connected) {
      bluetooth.printNewLine();
      
      if (selectedStyle == 2) {
        // ၁။ WiFi Name (Font Size 1 - ပုံမှန်အရွယ်အစား)
        bluetooth.printCustom(wifiName, 1, 1); 
        
        // ၂။ ငွေပမာဏ (Font Size 1 - WiFi Name နှင့် အရွယ်အစားတူ)
        bluetooth.printCustom("- $profilePrice -", 1, 1); 
        
        bluetooth.printNewLine();

        // ၃။ Voucher Code (Font Size 3 - အကြီးဆုံးအရွယ်အစားဖြင့် ပိုမိုကြီးမားစွာ)
        bluetooth.printCustom(voucherCode, 3, 1); 
      }

      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.paperCut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      appBar: AppBar(title: Text("Print Setting"), backgroundColor: Color(0xFF2A2A40)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("WiFi Name", style: TextStyle(color: Colors.white, fontSize: 16)),
            TextField(
              controller: TextEditingController(text: wifiName),
              onChanged: (value) => wifiName = value,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text("Select Bluetooth Printer", style: TextStyle(color: Colors.white, fontSize: 16)),
            DropdownButton<BluetoothDevice>(
              value: _selectedDevice,
              hint: Text("Choose Printer", style: TextStyle(color: Colors.white70)),
              dropdownColor: Color(0xFF2A2A40),
              items: _devices.map((device) {
                return DropdownMenuItem(
                  child: Text(device.name ?? "", style: TextStyle(color: Colors.white)),
                  value: device,
                );
              }).toList(),
              onChanged: (device) => _connect(device!),
            ),
          ],
        ),
      ),
    );
  }
}