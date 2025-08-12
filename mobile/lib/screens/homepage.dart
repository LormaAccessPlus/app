import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFFF9FAFB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Remove border radius
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
              },
            ),
            HoverListTile(
              icon: Icons.people,
              title: 'Classmates',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            HoverListTile(
              icon: Icons.book,
              title: 'Ledger',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            HoverListTile(
              icon: Icons.checklist,
              title: 'Checklist',
              onTap: () {
                Navigator.pop(context);
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
      body: Center(
        child: Text('Welcome to the Home Page!'),
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
  ));
}