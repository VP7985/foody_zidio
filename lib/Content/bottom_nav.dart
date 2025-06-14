import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foody_zidio/Admin/add_food.dart';
import 'package:foody_zidio/pages/ShoppingList.dart';
import 'package:foody_zidio/pages/home.dart';
import 'package:foody_zidio/pages/profile.dart';
import 'package:foody_zidio/pages/wallet.dart';
import 'package:foody_zidio/services/local_cache.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalCacheService _cacheService = LocalCacheService();
  bool _isAdmin = false;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    String? adminId = await _cacheService.getUserId('admin');
    setState(() {
      _isAdmin = adminId != null;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0; // Return to Home tab
      });
      return false;
    }
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true; // Allow app exit
  }

  @override
  Widget build(BuildContext context) {
    String? userId = _auth.currentUser?.uid;
    final List<Widget> _pages = [
      const Home(),
      userId != null
          ? ShoppingList(userId: userId)
          : const Center(child: Text("Please log in")),
      const Wallet(),
      const Profile(),
      _isAdmin
          ? const AddFood()
          : const Center(child: Text("Admin access required to add food items")),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'Add Food',
            ),
          ],
        ),
      ),
    );
  }
}