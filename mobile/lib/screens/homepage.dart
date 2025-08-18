import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Add this import
import 'schedule_screen.dart'; // Corrected import path for ScheduleScreen
import 'checklist_screen.dart'; // Import for ChecklistScreen
import 'grades_screen.dart'; // Make sure this import is present
import 'absences_screen.dart';
import 'account_settings_screen.dart';
import 'classmates_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomeContent(),         // Home tab
    ScheduleScreen(),      // Schedule tab
    GradesScreen(),        // Grades tab
    ProfileScreen(),       // Profile tab
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 4
          ? null
          : AppBar(
            ),
      drawer: Drawer(
        backgroundColor: Color(0xFFF9FAFB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 100, // Set your desired height here
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFF9FAFB),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'lib/assets/images/Logo.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Adjust the height of the box
            // Update ListTiles to have custom hover color
            HoverListTile(
              icon: Icons.calendar_today_rounded,
              title: 'Absences',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AbsencesScreen()),
                );
              },
            ),
            HoverListTile(
              icon: Icons.people,
              title: 'Classmates',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClassmatesScreen()),
                );
              },
            ),
            HoverListTile(
              icon: Icons.book,
              title: 'Ledger',
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/ledger'); // Navigate to Ledger page
              },
            ),
            HoverListTile(
              icon: Icons.checklist,
              title: 'Checklist',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChecklistScreen()),
                );
              },
            ),
            // Add a vertical line (Divider) below Checklist
            Divider(
              thickness: 0.5,
              color: Colors.black,
              indent: 0,
              endIndent: 0,
            ),
            HoverListTile(
              icon: Icons.account_box,
              title: 'Account Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountSettingsScreen()),
                );
              },
            ),
            HoverListTile(
              icon: Icons.privacy_tip,
              title: 'Privacy',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF08695A),
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade),
            label: 'Grades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Replace each ListTile with this custom widget for hover effect
class HoverListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const HoverListTile({
    required this.icon,
    required this.title,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  _HoverListTileState createState() => _HoverListTileState();
}

class _HoverListTileState extends State<HoverListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ListTile(
        leading: Icon(
          widget.icon,
          color: _isHovered ? Colors.white : Colors.black,
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: _isHovered ? Colors.white : Colors.black,
          ),
        ),
        tileColor: _isHovered ? Color(0xFF08695A) : Colors.transparent,
        onTap: widget.onTap,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false, // Remove the debug banner
  ));
}

// HomeContent widget for the Home page UI
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Text(
            "Welcome,",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 2),
          Text(
            "Dela Cruz, Juan F.",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFF08695A),
            ),
          ),
          Text(
            "Bachelor of Science in Information Technology - III",
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 18),

          // Current and Next Class Cards
          Row(
            children: [
              Expanded(
                child: ClassCard(
                  icon: Icons.access_time,
                  label: "Current Class",
                  subject: "Capstone 1",
                  time: "8:00 am - Room 403",
                  iconColor: Color(0xFF08695A),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ClassCard(
                  icon: Icons.access_time,
                  label: "Next Class",
                  subject: "Readings in Philippine History",
                  time: "9:30 am - Room 403",
                  iconColor: Color(0xFF08695A),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),

          // Announcements Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Announcements",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text("View all"),
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF08695A),
                ),
              ),
            ],
          ),
          // Announcements List
          AnnouncementCard(
            title: "Enrollment for A.Y 2025-2026",
            date: "04-26-25",
            content:
                "We equip students with global-ready skills to conquer any challenge! APPLY NOW: https://enroll.lorma.edu",
            color: Color(0xFFB9F5D8),
          ),
          AnnouncementCard(
            title: "Freshmen Application",
            date: "01-20-25",
            content:
                "We equip students with global-ready skills to conquer any challenge! APPLY NOW: https://enroll.lorma.edu",
            color: Color(0xFFD0F2FF),
          ),
          AnnouncementCard(
            title: "Installment Payment Plan",
            date: "01-06-25",
            content:
                "The Final Examination schedule for spring 2025 has been posted. Please check your personal schedule.",
            color: Color(0xFFFFF3CD),
          ),
        ],
      ),
    );
  }
}

class ClassCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subject;
  final String time;
  final Color iconColor;

  const ClassCard({
    required this.icon,
    required this.label,
    required this.subject,
    required this.time,
    required this.iconColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFB9F5D8)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subject,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF08695A),
              ),
            ),
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              time,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String date;
  final String content;
  final Color color;

  const AnnouncementCard({
    required this.title,
    required this.date,
    required this.content,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF08695A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text(
            date,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}