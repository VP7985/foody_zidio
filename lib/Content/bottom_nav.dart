import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';


class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late Widget currentPage;
  /*
  late Home homepage;
  late Profile profile;
  late Ordered order;
  late Wallet wallet;
  */

  @override
  void initState() {
    //pages = [homepage, order, wallet, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        bottomNavigationBar: CurvedNavigationBar(
          height: 65,
          backgroundColor: Colors.transparent,
          color: Colors.grey,
          animationDuration: Duration(milliseconds: 500),
          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          items: [
            Icon(
              Icons.home_outlined,
              color: Colors.black,
            ),
            Icon(
              Icons.shopping_bag_outlined,
              color: Colors.black,
            ),
            Icon(
              Icons.wallet_outlined,
              color: Colors.black,
            ),
            Icon(
              Icons.person_outline,
              color: Colors.black,
            )
          ],
        ),
        body: pages[currentTabIndex],
      ),
    );
  }
}
