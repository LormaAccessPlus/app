import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profile_page.dart';
import 'grades_page.dart';
import 'schedule_page.dart'; // { changed code }
import 'ledger_page.dart';
import 'checklist_page.dart'; // { changed code }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storage = const FlutterSecureStorage();

  static const String apiBase = 'http://10.0.2.2:8000';

  // primary color (hex 08695A) and light variants used for visuals
  final Color primaryColor = const Color(0xFF08695A);
  final Color primary50 = const Color(0xFF08695A).withOpacity(0.06);
  final Color primary100 = const Color(0xFF08695A).withOpacity(0.12);
  final Color primary200 = const Color(0xFF08695A).withOpacity(0.18);
  final Color primary400 = const Color(0xFF08695A).withOpacity(0.40);

  // auth form
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  // user / dashboard state
  bool _loggedIn = false;
  String _displayName = 'Guest User';
  String? _studentId;
  String? _prefix;
  String? _firstName;
  String? _middleName;
  String? _lastName;
  String? _suffix;
  int _currentIndex = 0;

  // sample dashboard data
  final List<Map<String, String>> _classes = [
    {'title': 'Capstone 1', 'time': '8:00 am', 'room': 'Room 403'},
    {
      'title': 'Readings in Philippine History',
      'time': '9:30 am',
      'room': 'Room 403',
    },
    {'title': 'Software Engineering', 'time': '11:00 am', 'room': 'Room 201'},
  ];
  final List<Map<String, String>> _announcements = [
    {
      'title': 'Enrollment for A.Y 2025-2026',
      'date': '04-26-25',
      'body':
          'We equip students with global-ready skills to conquer any challenge! APPLY NOW: https://enroll.lorma.edu',
    },
    {
      'title': 'Freshmen Application',
      'date': '01-20-25',
      'body':
          'We equip students with global-ready skills to conquer any challenge! APPLY NOW: https://enroll.lorma.edu',
    },
    {
      'title': 'Installment Payment Plan',
      'date': '01-06-25',
      'body':
          'The Final Examination schedule for spring 2025 has been posted. Please check your personal schedule',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkSavedAuth();
  }

  Future<void> _checkSavedAuth() async {
    final token = await _storage.read(key: 'token');
    final name = await _storage.read(key: 'user_name');
    final sid = await _storage.read(key: 'student_id');
    final prefix = await _storage.read(key: 'prefix');
    final first = await _storage.read(key: 'first_name');
    final middle = await _storage.read(key: 'middle_name');
    final last = await _storage.read(key: 'last_name');
    final suffix = await _storage.read(key: 'suffix');
    if (token != null) {
      setState(() {
        _loggedIn = true;
        _prefix = prefix;
        _firstName = first;
        _middleName = middle;
        _lastName = last;
        _suffix = suffix;
        _displayName =
            name ??
            _formatFullName(
              _prefix,
              _firstName,
              _middleName,
              _lastName,
              _suffix,
            ) ??
            'Student';
        _studentId = sid;
      });
    }
  }

  Future<void> _loginWithId() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final idNumber = _idController.text.trim();
    final password = _pwdController.text;

    try {
      final resp = await http
          .post(
            Uri.parse('$apiBase/api/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'student_id': idNumber, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final apiToken = body['token'] as String?;
        final user = body['user'] as Map<String, dynamic>?;
        final student = body['student'] as Map<String, dynamic>?;

        if (apiToken != null) {
          await _storage.write(key: 'token', value: apiToken);
        }
        if (user != null) {
          if (user['name'] != null) {
            await _storage.write(
              key: 'user_name',
              value: user['name'].toString(),
            );
          }
          if (user['student_id'] != null) {
            await _storage.write(
              key: 'student_id',
              value: user['student_id'].toString(),
            );
          }
          if (user['email'] != null) {
            await _storage.write(key: 'email', value: user['email'].toString());
          }
        }

        if (student != null) {
          if (student['Prefix'] != null) {
            await _storage.write(
              key: 'prefix',
              value: student['Prefix'].toString(),
            );
          }
          if (student['FirstName'] != null) {
            await _storage.write(
              key: 'first_name',
              value: student['FirstName'].toString(),
            );
          }
          if (student['MiddleName'] != null) {
            await _storage.write(
              key: 'middle_name',
              value: student['MiddleName'].toString(),
            );
          }
          if (student['LastName'] != null) {
            await _storage.write(
              key: 'last_name',
              value: student['LastName'].toString(),
            );
          }
          if (student['Suffix'] != null) {
            await _storage.write(
              key: 'suffix',
              value: student['Suffix'].toString(),
            );
          }

          if (student['BirthDate'] != null) {
            await _storage.write(
              key: 'dob',
              value: student['BirthDate'].toString(),
            );
          }
          if (student['BirthPlace'] != null) {
            await _storage.write(
              key: 'birthplace',
              value: student['BirthPlace'].toString(),
            );
          }
          if (student['Nationality'] != null) {
            await _storage.write(
              key: 'nationality',
              value: student['Nationality'].toString(),
            );
          }
        }

        setState(() {
          _loggedIn = true;
          _prefix = student?['Prefix'] as String?;
          _firstName = student?['FirstName'] as String?;
          _middleName = student?['MiddleName'] as String?;
          _lastName = student?['LastName'] as String?;
          _suffix = student?['Suffix'] as String?;
          _displayName =
              (user?['name'] as String?) ??
              _formatFullName(
                _prefix,
                _firstName,
                _middleName,
                _lastName,
                _suffix,
              ) ??
              idNumber;
          _studentId = (user?['student_id'] as String?) ?? idNumber;
        });
      } else {
        setState(() {
          _error = 'Login failed: ${resp.statusCode} ${resp.body}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Request failed: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'student_id');
    setState(() {
      _loggedIn = false;
      _displayName = 'Guest User';
      _studentId = null;
      _idController.clear();
      _pwdController.clear();
    });
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _formatFullName(
    String? prefix,
    String? first,
    String? middle,
    String? last,
    String? suffix,
  ) {
    final parts = <String>[];
    if (prefix != null && prefix.isNotEmpty) parts.add(prefix);
    if (first != null && first.isNotEmpty) parts.add(first);
    if (middle != null && middle.isNotEmpty) parts.add(middle);
    if (last != null && last.isNotEmpty) parts.add(last);
    if (suffix != null && suffix.isNotEmpty) parts.add(suffix);
    return parts.isEmpty ? '' : parts.join(' ');
  }

  Widget _authForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sign in with ID',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(labelText: 'ID number'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your ID number'
                          : null,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pwdController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 12),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _loginWithId,
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign in'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Updated header to match requested look (green name, subtitle, welcome)
  Widget _buildHeader() {
    final fullName = _formatFullName(
      _prefix,
      _firstName,
      _middleName,
      _lastName,
      _suffix,
    );
    final title = fullName.isNotEmpty ? fullName : _displayName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome,',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          // make title responsive and avoid overflow
          LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            'Bachelor of Science in Information Technology - III',
            style: TextStyle(fontSize: 12, color: Colors.black54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // New card UI for classes — responsive sizing and safer layout
  Widget _classCard(
    BuildContext context,
    Map<String, String> c, {
    bool highlighted = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.72).clamp(180.0, 320.0);

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted ? Colors.green.shade200 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: highlighted ? Colors.green.shade100 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.green.shade800, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    highlighted ? 'Current Class' : 'Next Class',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // title - prevent overflow
          Text(
            c['title'] ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: Colors.black54),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  c['time'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.location_on, size: 14, color: Colors.black54),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  c['room'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.green.shade100,
              child: Icon(
                Icons.arrow_forward,
                color: Colors.green.shade700,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          SizedBox(
            // allow the list to expand a bit on larger screens but avoid overflow on short screens
            height: 160,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _classes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final c = _classes[i];
                return _classCard(context, c, highlighted: i == 0);
              },
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Announcements',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('View all')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _announcements.map((a) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    // make the left bar match content height
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 6,
                          decoration: BoxDecoration(
                            color: primary400,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        a['title'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      a['date'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  a['body'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _schedulePage() => const SchedulePage(); // { changed code }
  Widget _gradesPage() {
    return const GradesPage();
  }

  Widget _profilePage() {
    return const ProfilePage();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // close drawer then logout
      Navigator.of(context).pop(); // close drawer
      _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sign in')),
        body: _authForm(),
      );
    }

    final titles = ['Home', 'Schedule', 'Grades', 'Profile'];
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        title: Text(titles[_currentIndex]),
        actions: [
          if (_currentIndex == 0)
            IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),

      // ADDED: navigation drawer
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: primaryColor),
                accountName: Text(
                  _formatFullName(
                        _prefix,
                        _firstName,
                        _middleName,
                        _lastName,
                        _suffix,
                      ).isNotEmpty
                      ? _formatFullName(
                          _prefix,
                          _firstName,
                          _middleName,
                          _lastName,
                          _suffix,
                        )
                      : _displayName,
                ),
                accountEmail: Text(_studentId ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    _initials(
                      _formatFullName(
                            _prefix,
                            _firstName,
                            _middleName,
                            _lastName,
                            _suffix,
                          ).isNotEmpty
                          ? _formatFullName(
                              _prefix,
                              _firstName,
                              _middleName,
                              _lastName,
                              _suffix,
                            )
                          : _displayName,
                    ),
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.event_busy),
                      title: const Text('Absences'),
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: navigate to Absences page
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('Classmates'),
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: navigate to Classmates page
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Ledger'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LedgerPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.check_box),
                      title: const Text('Checklist'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ChecklistPage()),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Account settings'),
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: navigate to Account Settings
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Privacy'),
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: navigate to Privacy
                      },
                    ),
                    const Divider(),
                    // keep a clear logout affordance inside list as well
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),

              // existing bottom logout button (kept for prominence)
            ],
          ),
        ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'Grades'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
