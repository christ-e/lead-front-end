import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../controller/loginControler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  LoginController loginController = Get.put(LoginController());
  final _formKey = GlobalKey<FormBuilderState>();

  Future<Map<String, String>> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId')?.toString();
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
      return {
        'name': data['name'],
        'email': data['email'],
        'phone': data['phone'],
      };
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool update = true;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, String>>(
          future: fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No user data found'));
            } else {
              final data = snapshot.data!;
              return FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      color: Colors.blueAccent,
                      width: double.infinity,
                      height: 80,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20),
                        child: update == false
                            ? Text(
                                "Hello, ${data['name']}",
                                style: TextStyle(
                                    fontSize: 30, color: Colors.white),
                              )
                            : Text(
                                "Edit Your Profile",
                                style: TextStyle(
                                    fontSize: 30, color: Colors.white),
                              ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 50, top: 70),
                                child: IconButton(
                                    onPressed: () {}, icon: Icon(Icons.edit)),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          FormBuilderTextField(
                            name: 'name',
                            enabled: update,
                            initialValue: data['name'],
                            decoration: InputDecoration(
                              labelText: 'UserName',
                            ),
                          ),
                          SizedBox(height: 10),
                          FormBuilderTextField(
                            name: 'email',
                            enabled: update,
                            initialValue: data['email'],
                            decoration: InputDecoration(
                              labelText: 'Email',
                            ),
                          ),
                          SizedBox(height: 10),
                          FormBuilderTextField(
                            name: 'phone',
                            enabled: update,
                            initialValue: data['phone'],
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                    AnimatedButton(
                      onPress: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          setState(() {});
                        } else {
                          print('validation failed');
                        }
                      },
                      width: 120,
                      height: 50,
                      text: 'Edit Profile',
                      isReverse: true,
                      selectedTextColor: Colors.black,
                      transitionType: TransitionType.TOP_CENTER_ROUNDER,
                      backgroundColor: Colors.blue.shade200,
                      borderColor: Colors.white,
                      borderWidth: 1,
                      borderRadius: 10,
                      animatedOn: AnimatedOn.onHover,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
