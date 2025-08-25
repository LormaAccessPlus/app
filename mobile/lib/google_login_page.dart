import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_page.dart';

class GoogleLoginPage extends StatefulWidget {
  @override
  _GoogleLoginPageState createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  // ✅ Use your Web Client ID from Firebase Console
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        "86688798470-d31ig188hhvieo5blapqlank0d90df90.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );

  final storage = const FlutterSecureStorage();
  bool _loading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return; // user cancelled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final idToken = googleAuth.idToken;
      print('idToken: $idToken');

      if (idToken == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to get idToken")));
        setState(() => _loading = false);
        return;
      }

      // ✅ FIX: Send "token" instead of "id_token"
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/google-login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // <-- add this
        },
        body: jsonEncode({'id_token': idToken}),
      );
      print('API status: ${response.statusCode}');
      print('API body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userName = data['user_name']; // <-- get user name

        // Save token and user name securely
        await storage.write(key: 'token', value: token);
        await storage.write(key: 'user_name', value: userName); // <-- save name

        // ✅ Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        print("Login failed: ${response.body}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login failed")));
      }
    } catch (error) {
      print("Error signing in: $error");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong")));
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _handleGoogleSignIn,
                child: Text("Login with Google"),
              ),
      ),
    );
  }
}

/// ✅ Helper API client (reuse token automatically)
class ApiClient {
  static final storage = FlutterSecureStorage();

  static Future<http.Response> get(String url) async {
    final token = await storage.read(key: 'token');
    return http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  static Future<http.Response> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    final token = await storage.read(key: 'token');
    return http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }
}
