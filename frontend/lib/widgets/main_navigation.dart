/// Haupt-Navigation für die Thriftshop-App
/// Statische BottomNavigationBar – nur der Body wechselt
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../exports.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabs = _buildTabs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    final rolle = auth.benutzer?.rolle;
    final isAdmin = rolle == 'Administrator' || rolle == 'Mitarbeiter';
    if (isAdmin != _isAdmin) {
      setState(() {
        _isAdmin = isAdmin;
        _tabs = _buildTabs();
        if (_currentIndex >= _tabs.length) {
          _currentIndex = _tabs.length - 1;
        }
      });
    }
  }

  List<Widget> _buildTabs() {
    final base = const [
      ProduktListeScreen(),
      WarenkorbScreen(),
      MeineBestellungenScreen(),
      ProfilScreen(),
    ];
    if (_isAdmin) {
      return [
        ...base,
        const ProduktverwaltungScreen(),
        const BestellverwaltungScreen(),
      ];
    }
    return base;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<BottomNavigationBarItem> _getNavItems() {
    final base = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Start',
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
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];
    if (_isAdmin) {
      return [
        ...base,
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Produkte',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt),
          label: 'Bestellungen',
        ),
      ];
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: _getNavItems(),
        ),
      ),
    );
  }
}
