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
          title: Text('Language Selection'),
        ),
        body: LanguageSelection(),
      ),
    );
  }
}

class LanguageSelection extends StatefulWidget {
  @override
  _LanguageSelectionState createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  Map<String, bool> _languages = {
    'English': false,
    'Spanish': false,
    'French': false,
    'German': false,
    'Chinese': false,
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ..._languages.keys.map((String key) {
            return CheckboxListTile(
              title: Text(key),
              value: _languages[key],
              onChanged: (bool? value) {
                setState(() {
                  _languages[key] = value ?? false;
                });
              },
            );
          }).toList(),
          SizedBox(height: 20),
          Text(
            'Selected Languages: ${_languages.entries.where((entry) => entry.value).map((entry) => entry.key).join(', ')}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
