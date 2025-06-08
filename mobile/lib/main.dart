import 'package:flutter/material.dart';
import 'screens/drawer.dart'; // Import your drawer

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Main App')),
      drawer: AppDrawer(), // Add this line
      body: Center(child: Text('Imbotido App')),
    ),
  ));
}
