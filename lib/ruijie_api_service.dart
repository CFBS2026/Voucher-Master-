import 'dart:convert';
import 'package:http/http.dart' as http;

class RuijieApiService {
  String gatewayIp;
  String username;
  String password;
  String? _sessionCookie;

  RuijieApiService({
    required this.gatewayIp,
    required this.username,
    required this.password,
  });

  // Gateway ထို့ Login ဝင်ရောက်ခြင်း
  Future<bool> login() async {
    final url = Uri.parse('http://$gatewayIp/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          _sessionCookie = rawCookie.split(';').first;
        }
        return true;
      }
      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  // Voucher Code အသစ်များ တောင်းဆိုခြင်း
  Future<List<String>> generateVouchers({
    required String profileId,
    required int count,
    int length = 8,
  }) async {
    final url = Uri.parse('http://$gatewayIp/api/voucher/create');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_sessionCookie != null) 'Cookie': _sessionCookie!,
        },
        body: jsonEncode({
          'profile_id': profileId,
          'amount': count,
          'length': length,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = data['vouchers'] ?? [];
        return list.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print("Generate Voucher Error: $e");
    }
    return [];
  }
}
