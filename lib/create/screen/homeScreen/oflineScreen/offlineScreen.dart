import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lead_application/create/screen/homeScreen/widget/bottom_nav.dart';
import 'package:lead_application/services/database_services.dart';
import 'package:http/http.dart' as http;

class Offlinescreen extends StatefulWidget {
  const Offlinescreen({super.key});

  @override
  State<Offlinescreen> createState() => _OfflinescreenState();
}

class _OfflinescreenState extends State<Offlinescreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late Future<List<Map<String, dynamic>>> _leads;

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  void _fetchLeads() {
    setState(() {
      _leads = _databaseService.getAllLeads();
    });
  }

  File? _image;
  Future<void> _submitForm(Map<String, dynamic> lead) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/api/store'));

    // Include any necessary headers here
    // request.headers['Authorization'] = 'Bearer your_api_token';

    request.fields['name'] = lead['name'] ?? "";
    request.fields['contact_number'] = lead['contact_number'] ?? "";
    request.fields['whats_app'] = lead['whats_app'] ?? "";
    request.fields['email'] = lead['email'] ?? "";
    request.fields['address'] = lead['address'] ?? "";
    request.fields['state'] = lead['state'] ?? "";
    request.fields['district'] = lead['district'] ?? "";
    request.fields['city'] = lead['city'] ?? "";
    request.fields['location_coordinates'] = lead['location_coordinates'] ?? "";
    request.fields['location_lat'] = lead['_lat'] ?? "";
    request.fields['location_log'] = lead['_log'] ?? "";
    request.fields['follow_up'] = lead['follow_up'] ?? "";
    request.fields['follow_up_date'] = lead['follow_up_date'] ?? "";
    request.fields['lead_priority'] = lead['lead_priority'] ?? "";

    if (_image != null && lead['image_path'] != null) {
      var file =
          await http.MultipartFile.fromPath('image_path', lead['image_path']);
      request.files.add(file);
    }

    try {
      var response = await request.send();

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Request successful");
        _showAlertDialog(context, 'Success', 'Form submitted successfully');
      } else {
        var responseBody = await response.stream.bytesToString();
        print("Request failed with status: ${response.statusCode}");
        print("Response body: $responseBody");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Form submission failed')));
        _showAlertDialog(context, 'Error', 'Form submission failed');
      }
    } catch (e) {
      print("Request failed with error: $e");
      _showAlertDialog(
          context, 'Error', 'Form submission failed due to an error');
    }
  }

  void _showAlertDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BottomNav(),
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads (Offline)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _leads,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No leads found.'));
                } else {
                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final lead = snapshot.data![index];
                      return ListTile(
                        title: Text(lead['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lead['contact_number'] ?? ""),
                            Text(lead['email'] ?? ""),
                            Text(lead['address'] ?? ""),
                            Text(lead['whats_app'] ?? ""),
                            Text(lead['follow_up_date'] ??
                                "********no date*******"),
                            Text(lead['location_coordinates'] ?? ""),
                            Text(lead['location_lat'] ?? ""),
                            Text(lead['location_log'] ?? ""),
                            Text(lead['image_path'] ?? ""),
                            Text(lead['state'] ?? ""),
                            Text(lead['city'] ?? ""),
                            Text(lead['district'] ?? ""),
                          ],
                        ),
                        trailing: ElevatedButton(
                            onPressed: () {
                              _submitForm(lead);
                            },
                            child: Text("Send")),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Sync action
              },
              child: Text('Sync'),
            ),
          ),
        ],
      ),
    );
  }
}
