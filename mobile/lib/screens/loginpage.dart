import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'lib/assets/images/Logo.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'LORMA ACCESS+',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 40),
            // Student ID Field
             TextField(
              decoration: InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Lorma Email Field
            TextField(
              decoration: InputDecoration(
                labelText: 'Lorma Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add your button logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Send',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white, // Changed text color to white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}