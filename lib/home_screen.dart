Import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text("Voucher Master"),
        backgroundColor: Color(0xFF2A2A40),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Color(0xFF2A2A40),
              child: ListTile(
                leading: Icon(Icons.print, color: Colors.blueAccent),
                title: Text("Print Setting", style: TextStyle(color: Colors.white)),
                subtitle: Text("ပရင်တာနှင့် စလစ်ပုံစံ ရွေးချယ်ရန်", style: TextStyle(color: Colors.white60)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
                onTap: () {
                  Navigator.pushNamed(context, '/print_setting');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}