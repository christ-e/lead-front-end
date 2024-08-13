import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:lead_application/create/screen/homeScreen/editScreen/add_deatils_screen.dart';
import 'package:lead_application/create/screen/homeScreen/listScreen/list_deatils_screen.dart';
import 'package:lead_application/create/screen/homeScreen/mapScreen/mapmyindia/location.dart';
import 'package:lead_application/create/screen/homeScreen/mapScreen/mapmyindia/mapScreen.dart';
import 'package:lead_application/create/screen/homeScreen/oflineScreen/offlineScreen.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    ListScreen(),
    AddDetailsScreen(),
    Offlinescreen(),

    MyHomePage(),
    MapScreen(),
    // GoogleMapScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.list_alt, size: 30),
          Icon(Icons.add_chart_outlined, size: 30),
          Icon(Icons.wifi_off, size: 30),
          Image(
            image: AssetImage("assets/images/map_icon.png"),
            height: 35,
          ),
          Image(
            image: AssetImage("assets/images/map_icon.png"),
            height: 35,
          ),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 137, 180, 255),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: _onItemTapped,
        letIndexChange: (index) => true,
      ),
    );
  }
}
