import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lead_application/controller/loginControler.dart';
import 'package:lead_application/create/screen/drawerScreen/loggerScreen.dart';
import 'package:lead_application/create/screen/drawerScreen/settingsScreen.dart';
import 'package:lead_application/db_connection/services/database_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../create/screen/drawerScreen/locationTravelledScreen.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late Future<Map<String, String>> _userData;

  @override
  void initState() {
    super.initState();
    _userData = fetchUserData();
  }

  // Future<void> storeUserName(String name) async {
  //   final username = await SharedPreferences.getInstance();
  //   await username.setString('userName', name);
  // }

  Future<Map<String, String>> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId')?.toString();
    LoginController loginController = Get.put(LoginController());
    var token = loginController.logtoken;

    if (userId == null) {
      throw Exception('User ID not found');
    }

    final url = Uri.parse('http://127.0.0.1:8000/api/user/name/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // await storeUserName(data['name']);
      final username = await SharedPreferences.getInstance();
      await username.setString('userName', data['name']);
      return {
        'name': data['name'],
        'email': data['email'],
        'phone': data['phone'],
      };
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> _checkDataAndLogout(BuildContext context) async {
    final DatabaseService _databaseService = DatabaseService.instance;
    LoginController loginController = Get.put(LoginController());

    final List<Map<String, dynamic>> leads =
        await _databaseService.getAllLeads();

    if (leads.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Unsynced Data"),
            content: Text(
                "There is data that needs to be synced. Do you want to proceed with logout?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  loginController.logout(context);
                },
                child: Text("Logout"),
              ),
            ],
          );
        },
      );
    } else {
      loginController.logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: FutureBuilder<Map<String, String>>(
              future: _userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final userData = snapshot.data;
                  return Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?['name'] ?? 'User Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          userData?['email'] ?? 'User Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text('Logger'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Logger(),
                  ));
            },
          ),
          ListTile(
            leading: Image.asset(
              "assets/images/map_icon.png",
              scale: 10,
            ),
            title: Text('Location Travelled'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationTrack(),
                  ));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ));
            },
          ),
          ListTile(
            leading: Icon(Icons.login_outlined),
            title: Text('LogOut'),
            onTap: () {
              Navigator.pop(context);
              _checkDataAndLogout(context);
            },
          ),
        ],
      ),
    );
  }
}
