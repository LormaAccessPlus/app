import 'package:flutter/material.dart';
import 'screens/loginpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lorma Access+',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: LoginPage(), // Set LoginPage as the initial screen
    );
  }
}
