import 'package:flutter/material.dart';
import 'package:memory_ez/pages/home/_home.dart';
import 'package:memory_ez/pages/home/_public.dart';

import '../../services/auth.dart';
import '_profile.dart';

class NavigationItem {
  final String title;
  final IconData icon;
  final Widget widget;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.widget,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<NavigationItem> _navigationItems = [
    NavigationItem(
      title: 'Home',
      icon: Icons.home,
      widget: const Home(),
    ),
    NavigationItem(
      title: 'Public Themes',
      icon: Icons.public,
      widget: const Public(),
    ),
    NavigationItem(
      title: 'Profile',
      icon: Icons.person,
      widget: const Profile(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MemoryEZ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: _navigationItems[_selectedIndex].widget,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navigationItems
            .map((NavigationItem navigationItem) => BottomNavigationBarItem(
                  icon: Icon(navigationItem.icon),
                  label: navigationItem.title,
                ))
            .toList(),
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
