import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivationScreen extends StatefulWidget {
  @override
  _ActivationScreenState createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _gmailController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  bool isLoading = false;

  void verifyAndActivate() async {
    setState(() {
      isLoading = true;
    });

    String gmail = _gmailController.text.trim();
    String licenseKey = _keyController.text.trim();

    if (gmail.isEmpty || !gmail.endsWith("@gmail.com")) {
      showError("ကျေးဇူးပြု၍ မှန်ကန်သော Ruijie Gmail ထည့်သွင်းပါ။");
      return;
    }

    if (licenseKey.isEmpty || !licenseKey.startsWith("VF-")) {
      showError("ကျေးဇူးပြု၍ မှန်ကန်သော License Key (VF-XXXXXXXX) ထည့်သွင်းပါ။");
      return;
    }

    await Future.delayed(Duration(seconds: 1));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isActivated', true);
    await prefs.setString('ruijie_gmail', gmail);
    await prefs.setString('license_key', licenseKey);

    Navigator.pushReplacementNamed(context, '/home');

    setState(() {
      isLoading = false;
    });
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Voucher Master", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Ruijie Gateway အတွက် လိုင်စင်ကီး ထည့်သွင်းပါ။", style: TextStyle(color: Colors.white70, fontSize: 14)),
            SizedBox(height: 30),
            TextField(
              controller: _gmailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Ruijie Account Gmail",
                labelStyle: TextStyle(color: Colors.white70),
                hintText: "example@gmail.com",
                hintStyle: TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _keyController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "License Key",
                labelStyle: TextStyle(color: Colors.white70),
                hintText: "VF-XXXXXXXX",
                hintStyle: TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E5631)),
                onPressed: isLoading ? null : verifyAndActivate,
                child: isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("ဆက်သွားရန် →", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
