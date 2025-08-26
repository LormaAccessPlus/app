import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';

class GoogleLoginPage extends StatefulWidget {
  const GoogleLoginPage({super.key});

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

  final _storage = const FlutterSecureStorage();
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
      final serverAuthCode = googleAuth.serverAuthCode;
      print('serverAuthCode: $serverAuthCode');

      if (serverAuthCode == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to get serverAuthCode")));
        setState(() => _loading = false);
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.50:8000/api/google-login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'server_auth_code': serverAuthCode}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final apiToken = body['token'] as String?;
        final user = body['user'] as Map<String, dynamic>?;

        if (apiToken != null) await _storage.write(key: 'token', value: apiToken);
        if (user != null) {
          if (user['name'] != null) await _storage.write(key: 'user_name', value: user['name'].toString());
          if (user['id'] != null) await _storage.write(key: 'user_id', value: user['id'].toString());
          if (user['student_id'] != null) await _storage.write(key: 'student_id', value: user['student_id'].toString()); // <-- store DB id
        }

        // navigate after storing
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
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
