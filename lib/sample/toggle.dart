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
          title: Text('Toggle Switch Example'),
        ),
        body: Center(
          child: ToggleSwitchExample(),
        ),
      ),
    );
  }
}

class ToggleSwitchExample extends StatefulWidget {
  @override
  _ToggleSwitchExampleState createState() => _ToggleSwitchExampleState();
}

class _ToggleSwitchExampleState extends State<ToggleSwitchExample> {
  bool s1 = true;
  bool s2 = false;

  void t1(bool value) {
    setState(() {
      s1 = s2;
    });
  }

  void t2(bool value) {
    setState(() {
      s2 = s1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Switch(
            value: s1,
            onChanged: t1,
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          ),
          SizedBox(height: 20),
          Text(
            s1 ? 'Switch is ON' : 'Switch is OFF',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            s1.toString(),
            style: TextStyle(fontSize: 20),
          ),
          Switch(
            value: s2,
            onChanged: t2,
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          ),
          SizedBox(height: 20),
          Text(
            s2 ? 'Switch is ON' : 'Switch is OFF',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            s2.toString(),
            style: TextStyle(fontSize: 20),
          ),
        ]);
  }
}
