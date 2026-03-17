import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.app_registration),
          label: 'Register',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
        BottomNavigationBarItem(
          icon: Icon(Icons.emergency),
          label: 'Emergency',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.videocam),
          label: 'Live Report',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Tutorials'),
      ],
    );
  }
}
