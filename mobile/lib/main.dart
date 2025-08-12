import 'package:flutter/material.dart';
import 'screens/loginpage.dart';
import 'screens/homepage.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => LoginPage(),
      '/home': (context) => HomePage(),
    },
  ));
}
