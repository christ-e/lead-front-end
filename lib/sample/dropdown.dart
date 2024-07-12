import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Kerala Districts Dropdown'),
        ),
        body: DistrictDropdown(),
      ),
    );
  }
}

class DistrictDropdown extends StatefulWidget {
  @override
  _DistrictDropdownState createState() => _DistrictDropdownState();
}

class _DistrictDropdownState extends State<DistrictDropdown> {
  final List<Map<String, dynamic>> districts = [
    {'name': 'Alappuzha', 'id': 1},
    {'name': 'Ernakulam', 'id': 2},
  ];

  String? selectedDistrict;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: DropdownButton<String>(
            hint: Text('Select a District'),
            value: selectedDistrict,
            items: districts.map((e) {
              return DropdownMenuItem<String>(
                value: e['id'].toString(),
                child: Text(e['name']),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedDistrict = newValue;
                // log(newValue.toString());
                print(newValue.toString());
              });
            }));
  }
}
