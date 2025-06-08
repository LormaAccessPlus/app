import 'package:flutter/material.dart';
import 'widgets/bottom_navbar.dart';
import 'screens/drawer.dart'; // Import your drawer

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BottomNavbar(),
  ));
}
