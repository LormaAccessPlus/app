import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Avatar with Edit Icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.green[100],
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 64, color: Colors.grey[700]),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, color: Color(0xFF08695A), size: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Juan F. Dela Cruz',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              'Student ID: 2212111',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.edit, size: 18),
              label: Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF08695A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),
            SizedBox(height: 24),
            // Basic Information Card
            ProfileInfoCard(
              title: 'Basic Information',
              children: [
                ProfileInfoRow(label: 'Full Name:', value: 'Juan Flora Dela Cruz'),
                ProfileInfoRow(label: 'Date of Birth:', value: 'March 10, 1957'),
                ProfileInfoRow(label: 'Gender:', value: 'Male'),
                ProfileInfoRow(label: 'Nationality:', value: 'Saudi Arabia'),
              ],
            ),
            SizedBox(height: 16),
            // Contact Information Card
            ProfileInfoCard(
              title: 'Contact Information',
              children: [
                ProfileInfoRow(label: 'Email', value: 'juan.delacruz@lorma.edu'),
                ProfileInfoRow(label: 'Phone', value: '(111)911-2000'),
                ProfileInfoRow(label: 'Address', value: 'Saudi Arabia'),
                ProfileInfoRow(label: 'Nationality:', value: 'Saudi Arabia'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileInfoCard({
    required this.title,
    required this.children,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoRow({
    required this.label,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}