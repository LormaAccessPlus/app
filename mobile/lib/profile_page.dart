import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();

  String? fullName;
  String? studentId;
  String? prefix;
  String? firstName;
  String? middleName;
  String? lastName;
  String? suffix;

  String? email;
  String? phone;
  String? address;
  String? dob;
  String? birthPlace;
  String? gender;
  String? nationality;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final storedName = await _storage.read(key: 'user_name');
    final sid = await _storage.read(key: 'student_id');
    final p = await _storage.read(key: 'prefix');
    final f = await _storage.read(key: 'first_name');
    final m = await _storage.read(key: 'middle_name');
    final l = await _storage.read(key: 'last_name');
    final s = await _storage.read(key: 'suffix');
    final e = await _storage.read(key: 'email');
    final ph = await _storage.read(key: 'phone');
    final ad = await _storage.read(key: 'address');
    final d = await _storage.read(key: 'dob');
    final bp = await _storage.read(key: 'birthplace');
    final g = await _storage.read(key: 'gender');
    final nat = await _storage.read(key: 'nationality');

    // debug: print loaded storage values to console
    print('Profile load -> user_name:$storedName student_id:$sid dob:$d birthplace:$bp nationality:$nat prefix:$p first:$f last:$l');

    setState(() {
      // prefer storedName, otherwise compose from parts
      final composed = _formatFullName(p, f, m, l, s);
      fullName = storedName ?? (composed.isNotEmpty ? composed : null);
      studentId = sid;
      prefix = p;
      firstName = f;
      middleName = m;
      lastName = l;
      suffix = s;
      email = e;
      phone = ph;
      address = ad;
      dob = d;
      birthPlace = bp;
      gender = g;
      nationality = nat;
    });
  }

  String _formatFullName(String? p, String? f, String? m, String? l, String? s) {
    final parts = <String>[];
    if (p != null && p.isNotEmpty) parts.add(p);
    if (f != null && f.isNotEmpty) parts.add(f);
    if (m != null && m.isNotEmpty) parts.add(m);
    if (l != null && l.isNotEmpty) parts.add(l);
    if (s != null && s.isNotEmpty) parts.add(s);
    return parts.join(' ');
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(value ?? '-', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final composed = _formatFullName(prefix, firstName, middleName, lastName, suffix);
    final displayName = (composed.isNotEmpty) ? composed : (fullName ?? 'Student');

    // TEMP: show raw debug values if something missing
    final debugText = 'DOB:${dob ?? "-"}  BP:${birthPlace ?? "-"}  NAT:${nationality ?? "-"}';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Column(
        children: [
          // small debug row (remove after verifying)
          Padding(padding: const EdgeInsets.only(bottom:8.0), child: Text(debugText, style: TextStyle(color: Colors.red.shade700, fontSize: 12))),
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.green.shade50,
            child: Text(
              _initials(displayName),
              style: TextStyle(fontSize: 28, color: Colors.green.shade700, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (studentId != null) Padding(padding: const EdgeInsets.only(top: 6.0), child: Text('Student ID: $studentId', style: const TextStyle(color: Colors.black54))),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // TODO: navigate to edit profile screen
            },
          ),
          const SizedBox(height: 20),

          // Basic Information card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Basic Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(),
                  _infoRow('Full Name:', displayName),
                  _infoRow('Birth Date:', dob),
                  _infoRow('Birth Place:', birthPlace),
                  _infoRow('Gender:', gender),
                  _infoRow('Nationality:', nationality),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Contact Information card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(),
                _infoRow('Email', email ?? (studentId != null ? '$studentId@lorma.edu' : null)),
                _infoRow('Phone', phone),
                _infoRow('Address', address),
                _infoRow('Nationality', nationality),
              ]),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}