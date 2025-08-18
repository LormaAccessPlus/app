import 'package:flutter/material.dart';
import 'screens/homepage.dart';
import 'screens/loginpage.dart';
import 'screens/ledger_screen.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
    routes: {
      '/ledger': (context) => LedgerScreen(),
    },
  ));
}
