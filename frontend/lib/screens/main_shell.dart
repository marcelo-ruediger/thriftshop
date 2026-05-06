/// Main-Shell für mobile/desktop Navigation
/// Umschaltung zwischen BottomNavigationBar und NavigationRail

import 'package:flutter/material.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    if (isDesktop) {
      return DesktopShell(child: widget.child, currentIndex: _currentIndex);
    } else {
      return MobileShell(child: widget.child, currentIndex: _currentIndex);
    }
  }
}

class MobileShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MobileShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Warenkorb',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Bestellungen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    // Navigation logic hier
    switch (index) {
      case 0:
        // Home
        break;
      case 1:
        // Warenkorb
        break;
      case 2:
        // Bestellungen
        break;
      case 3:
        // Profil
        break;
    }
  }
}

class DesktopShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const DesktopShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) =>
                _onDestinationSelected(context, index),
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: Text('Warenkorb'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('Bestellungen'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_circle_outlined),
                selectedIcon: Icon(Icons.account_circle),
                label: Text('Profil'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  void _onDestinationSelected(BuildContext context, int index) {
    // Navigation logic hier
    switch (index) {
      case 0:
        // Home
        break;
      case 1:
        // Warenkorb
        break;
      case 2:
        // Bestellungen
        break;
      case 3:
        // Profil
        break;
    }
  }
}
