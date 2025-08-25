import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'google_login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  int _currentIndex = 0;

  String _displayName = 'Guest User';

  // sample data - replace with real API calls
  final List<Map<String, String>> _classes = [
    {
      'title': 'Capstone 1',
      'time': '8:00 am - Room 403',
    },
    {
      'title': 'Readings in Philippine History',
      'time': '9:30 am - Room 403',
    },
    {
      'title': 'Software Engineering',
      'time': '11:00 am - Room 201',
    },
  ];

  final List<Map<String, String>> _announcements = [
    {
      'title': 'Enrollment for A.Y 2025-2026',
      'date': '04-26-25',
      'body':
          'We enjoin students with global-ready skills to conquer any challenge! APPLY NOW: https://enroll.lorma.edu'
    },
    {
      'title': 'Freshmen Application',
      'date': '01-20-25',
      'body':
          'We accept students with global-ready skills to conquer any challenge! APPLY NOW: https://enroll.lorma.edu'
    },
    {
      'title': 'Installment Payment Plan',
      'date': '01-06-25',
      'body': 'The Final Examination schedule for spring 2025 has been posted.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await _storage.read(key: 'user_name');
    if (mounted) {
      setState(() {
        _displayName = name ?? 'Guest User';
      });
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _confirmLogout() async {
    final should = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Logout')),
        ],
      ),
    );

    if (should == true) {
      // sign out from Google, clear stored token and navigate to login
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'user_name');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GoogleLoginPage()),
      );
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green.shade100,
            child: Text(
              _initials(_displayName),
              style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // Text('Dela Cruz, Juan F.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                // SizedBox(height: 4),
                // Text('Bachelor of Science in Information Technology - III', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Bachelor of Science in Information Technology - III', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _confirmLogout),
        ],
      ),
    );
  }

  Widget _buildClassCards() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _classes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final c = _classes[i];
          return Container(
            width: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.green.shade100),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(c['time'] ?? '', style: const TextStyle(color: Colors.black54)),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.access_time, color: Colors.green.shade400, size: 20),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncements() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('Announcements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Spacer(),
              Text('View all', style: TextStyle(color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: _announcements.map((a) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(a['title'] ?? ''),
                  subtitle: Text(a['body'] ?? ''),
                  trailing: Text(a['date'] ?? ''),
                  onTap: () {
                    // TODO: show announcement detail
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _homeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          _buildClassCards(),
          const SizedBox(height: 6),
          _buildAnnouncements(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _schedulePage() {
    return Center(child: Text('Schedule page - implement your schedule UI', style: TextStyle(fontSize: 16)));
  }

  Widget _gradesPage() {
    return Center(child: Text('Grades page - implement grades UI', style: TextStyle(fontSize: 16)));
  }

  Widget _profilePage() {
    return Center(child: Text('Profile page - implement profile UI', style: TextStyle(fontSize: 16)));
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Home', 'Schedule', 'Grades', 'Profile'];
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        title: Text(titles[_currentIndex]),
        actions: [
          if (_currentIndex == 0)
            IconButton(icon: const Icon(Icons.refresh), onPressed: () {
              // TODO: reload data for home
            }),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _homeContent(),
          _schedulePage(),
          _gradesPage(),
          _profilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'Grades'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
