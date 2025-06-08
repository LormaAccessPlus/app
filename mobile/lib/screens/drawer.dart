import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // Track hovered index
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final hoverColor = const Color(0xFF08695A);

    // Build one drawer item with hover effect
    Widget buildDrawerItem({
      required IconData icon,
      required String title,
      required int index,
      required VoidCallback onTap,
    }) {
      final isHovered = _hoveredIndex == index;

      return MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = null),
        child: Container(
          color: isHovered ? hoverColor : Colors.transparent,
          child: ListTile(
            leading: Icon(
              icon,
              color: isHovered ? Colors.white : Colors.black,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isHovered ? Colors.white : Colors.black,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              onTap();
            },
          ),
        ),
      );
    }

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // No radius, sharp corners
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Logo row with close button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/Lorma_access+_logo.png',
                  height: 80, // Small logo
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1), // Horizontal line
          buildDrawerItem(
            icon: Icons.event_available,
            title: 'Absences',
            index: 0,
            onTap: () {
              // Navigate to Absences page
            },
          ),
          buildDrawerItem(
            icon: Icons.group_outlined,
            title: 'Classmates',
            index: 1,
            onTap: () {
              // Navigate to Classmates page
            },
          ),
          buildDrawerItem(
            icon: Icons.menu_book_outlined,
            title: 'Ledger',
            index: 2,
            onTap: () {
              // Navigate to Ledger page
            },
          ),
          buildDrawerItem(
            icon: Icons.check_box_outlined,
            title: 'Checklist',
            index: 3,
            onTap: () {
              // Navigate to Checklist page
            },
          ),
          const Divider(height: 1, thickness: 1),
          buildDrawerItem(
            icon: Icons.manage_accounts_outlined,
            title: 'Account Settings',
            index: 4,
            onTap: () {
              // Navigate to Account Settings page
            },
          ),
          buildDrawerItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            index: 5,
            onTap: () {
              // Navigate to Privacy page
            },
          ),
        ],
      ),
    );
  }
}
