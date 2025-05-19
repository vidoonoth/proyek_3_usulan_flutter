import 'package:flutter/material.dart';

class BottomNavComponent extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavComponent({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return BottomNavigationBar(
      backgroundColor: const Color(0xFFF8FAFC),
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedFontSize: isSmallScreen ? 10 : 12,
      unselectedFontSize: isSmallScreen ? 10 : 12,
      iconSize: isSmallScreen ? 20 : 24,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Buku',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Riwayat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'Informasi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
    );
  }
}
