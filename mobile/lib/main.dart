import 'package:flutter/material.dart';
import 'home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lorma App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(), // ensure HomePage is the first screen
    );
  }
}
