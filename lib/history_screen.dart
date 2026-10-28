import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/voucher_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  double _totalRevenue = 0.0;
  List<Voucher> _vouchers = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    var list = await DatabaseHelper.instance.getAllVouchers();
    var rev = await DatabaseHelper.instance.getTotalRevenue();
    setState(() {
      _vouchers = list;
      _totalRevenue = rev;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History & Revenue")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blueDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Revenue:", style: TextStyle(fontSize: 18, color: Colors.white)),
                Text("${_totalRevenue.toStringAsFixed(0)} Ks", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _vouchers.length,
              itemBuilder: (context, index) {
                final v = _vouchers[index];
                return ListTile(
                  title: Text(v.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(v.profileName),
                  trailing: Text("${v.price.toStringAsFixed(0)} Ks"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
