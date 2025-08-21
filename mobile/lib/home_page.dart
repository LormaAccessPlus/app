import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'google_login_page.dart';

class HomePage extends StatelessWidget {
  final storage = FlutterSecureStorage();

  Future<void> _logout(BuildContext context) async {
    await storage.delete(key: 'token'); // clear saved token
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GoogleLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Text("Welcome! You are logged in 🎉"),
      ),
    );
  }
}
