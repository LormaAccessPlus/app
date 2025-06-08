import 'package:flutter/material.dart';
import 'screens/drawer.dart'; // Import your drawer

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF08695A),
        title: Row(
          children: [
            Image.asset(
              'assets/images/Lorma_access+_logo.png',
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text('Lorma Access Plus'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Notification logic here
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Profile logic here
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Welcome to Lorma Access Plus!')),
    );
  }
}
