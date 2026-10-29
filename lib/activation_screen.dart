import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() =>
      _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _gmailController =
      TextEditingController();

  final TextEditingController _keyController =
      TextEditingController();

  bool isLoading = false;

  Future<void> verifyAndActivate() async {
    if (isLoading) return;

    final String gmail =
        _gmailController.text.trim().toLowerCase();

    final String licenseKey =
        _keyController.text.trim().toUpperCase();

    if (gmail.isEmpty ||
        !RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$')
            .hasMatch(gmail)) {
      _showError('မှန်ကန်သော Gmail လိပ်စာ ထည့်သွင်းပါ။');
      return;
    }

        // အကယ်၍ License Key ကို တင်းတင်းကျပ်ကျပ် မစစ်ဆေးဘဲ အလွယ်စမ်းချင်လျှင် ဤသို့ပြင်ပါ
    if (gmail.isEmpty || !RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(gmail)) {
      _showError('မှန်ကန်သော Gmail လိပ်စာ ထည့်သွင်းပါ။');
      return;
    }

    if (licenseKey.isEmpty) {
      _showError('License Key ထည့်သွင်းပါ။');
      return;
    }


    setState(() {
      isLoading = true;
    });

    try {
      // TEMPORARY DEMO ONLY:
      // ဤအပိုင်းသည် License Key အစစ်ဟုတ်မဟုတ်
      // Server မှ စစ်ဆေးပေးခြင်း မဟုတ်သေးပါ။
      //
      // စီးပွားဖြစ်အသုံးပြုရန် License Server API
      // ဖြင့် အစားထိုးရပါမည်။

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool('isActivated', true);
      await prefs.setString('ruijie_gmail', gmail);
      await prefs.setString('license_key', licenseKey);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showError('Activation မအောင်မြင်ပါ။ ထပ်မံကြိုးစားပါ။');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  void dispose() {
    _gmailController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.wifi,
                  color: Colors.greenAccent,
                  size: 52,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Voucher Master',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Ruijie Gateway Voucher Management',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: _gmailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Ruijie Account Gmail',
                    labelStyle:
                        const TextStyle(color: Colors.white70),
                    hintText: 'example@gmail.com',
                    hintStyle:
                        const TextStyle(color: Colors.white30),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _keyController,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'License Key',
                    labelStyle:
                        const TextStyle(color: Colors.white70),
                    hintText: 'VM-A12345678',
                    hintStyle:
                        const TextStyle(color: Colors.white30),
                    prefixIcon: const Icon(
                      Icons.vpn_key_outlined,
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        isLoading ? null : verifyAndActivate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E5631),
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Activate & Continue →',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Voucher Master License Activation',
                    textAlign: TextAlign.center,
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
      ),
    );
  }
}