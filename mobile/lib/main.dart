import 'package:flutter/material.dart';
import 'screens/drawer.dart'; // Import your drawer

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, // Removed the debug banner
    home: Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF08695A), 
        title: Row(
          children: [
        
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
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Profile logic here
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Imbotido App')),
    ),
  ));
}
