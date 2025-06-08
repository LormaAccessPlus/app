import 'package:flutter/material.dart';
import 'package:mobile/widgets/drawer.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    // Remove MaterialApp from here
    return const HomePage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    Center(child: Text('Home Page')),
    Center(child: Text('Schedule Page')),
    Center(child: Text('Grades Page')),
    Center(child: Text('Profile Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const AppDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: PhysicalModel(
        color: Colors.transparent,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(1), 
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF08695A),
          unselectedItemColor: Colors.black,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          onTap: _onItemTapped,
          selectedLabelStyle: TextStyle(color: Colors.black),
          unselectedLabelStyle: TextStyle(color: Colors.black),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grade_outlined),
              label: 'Grades',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
