import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sp_grocery_list/pages/homepage.dart';
import 'package:sp_grocery_list/pages/shopping_page.dart';
import 'package:sp_grocery_list/pages/user_account_page.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {

  int _selectedIndex = 0;

  // List of pages for each tab
  final List<Widget> _pages = [
    HomePage(),
    ShoppingPage(),
    UserAccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar:
      Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
          child: GNav(
            backgroundColor: Colors.white,
            color: Colors.black,
            activeColor: Colors.black,
            tabBorderRadius: 16,
            tabBackgroundColor: Color(0xFFAAEA61),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            iconSize: 35,
            onTabChange: (index){
              setState(() {
                _selectedIndex = index; // Change page
              });
            },
            tabs: [
              GButton(icon: Icons.home),
              GButton(icon: Icons.shopping_cart),
              GButton(icon: Icons.account_circle),
            ]
          ),
        ),
      ),
    );
  }
}
