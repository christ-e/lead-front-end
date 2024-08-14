import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lead_application/constant/api_Endpoints.dart';
import 'package:lead_application/create/screen/homeScreen/editScreen/add_deatils_screen.dart';
import 'package:lead_application/widgets/bottom_nav.dart';
import 'package:lead_application/db_connection/services/database_services.dart';
import 'package:http/http.dart' as http;

import '../../../../controller/loginControler.dart';

class Offlinescreen extends StatefulWidget {
  const Offlinescreen({super.key});

  @override
  State<Offlinescreen> createState() => _OfflinescreenState();
}

class _OfflinescreenState extends State<Offlinescreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late Future<List<Map<String, dynamic>>> _leads;
  bool isLoading = false;
  LoginController loginController = Get.put(LoginController());

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

  // File? _image;

  Future<void> _submitForm(Map<String, dynamic> lead) async {
    var request = http.MultipartRequest('POST',
        Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.storeData));
    // 'POST', Uri.parse('http://127.0.0.1:8000/api/store'));

    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer ${loginController.logtoken}';

    request.fields['name'] = lead['name'] ?? "";
    request.fields['user_id'] = lead['user_id'].toString();
    request.fields['contact_number'] = lead['contact_number'] ?? "";
    request.fields['whats_app'] = lead['whats_app'] ?? 0;
    request.fields['email'] = lead['email'] ?? "";
    request.fields['address'] = lead['address'] ?? "";
    request.fields['state'] = lead['state'] ?? "";
    request.fields['district'] = lead['district'] ?? "";
    request.fields['city'] = lead['city'] ?? "";
    request.fields['location_coordinates'] = lead['location_coordinates'] ?? "";
    request.fields['location_lat'] = lead['location_lat'] ?? "";
    request.fields['location_log'] = lead['location_log'] ?? "";
    request.fields['follow_up'] = lead['follow_up'] ?? "";
    request.fields['follow_up_date'] = lead['follow_up_date'] ?? "";
    request.fields['lead_priority'] = lead['lead_priority'] ?? "";

    if (lead['image_path'] != null && lead['image_path'] != null) {
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

  Future<void> _syncAllLeads() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> leads = await _leads;
      for (var lead in leads) {
        await _submitForm(lead);
      }
      _showAlertDialog(context, 'Success', 'All leads have been synced.');
    } catch (e) {
      print("Sync failed with error: $e");
      _showAlertDialog(context, 'Error', 'Sync failed due to an error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteLead(int id, bool snack) async {
    try {
      await _databaseService.deleteLead(id);
      _fetchLeads(); // Refresh the list
      if (snack == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lead deleted')));
      }
    } catch (e) {
      if (snack == true) {
        print("Delete failed with error: $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete lead')));
      }
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
                Navigator.of(context).pop();
                if (title == 'Success') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BottomNav(),
                    ),
                  );
                }
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
              builder: (context, leads) {
                if (leads.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (leads.hasError) {
                  return Center(child: Text('Error: ${leads.error}'));
                } else if (!leads.hasData || leads.data!.isEmpty) {
                  return Center(child: Text('No leads found.'));
                } else {
                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: leads.data!.length,
                    itemBuilder: (context, index) {
                      final lead = leads.data![index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Lead Details'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                            'Contact Number: ${lead['contact_number'] ?? "N/A"}'),
                                        Text(
                                            'Email: ${lead['email'] ?? "No Email"}'),
                                        Text(
                                            'Address: ${lead['address'] ?? "N/A"}'),
                                        // Uncomment the following lines if needed
                                        Text(
                                            'WhatsApp: ${lead['whats_app'] ?? "N/A"}'),
                                        Text(
                                            'Follow Up Date: ${lead['follow_up_date'] ?? "N/A"}'),
                                        Text(
                                            'Location Coordinates: ${lead['location_coordinates'] ?? "N/A"}'),
                                        // Text(
                                        //     'Location Latitude: ${lead['location_lat'] ?? "N/A"}'),
                                        // Text(
                                        //     'Location Longitude: ${lead['location_log'] ?? "N/A"}'),
                                        Text(
                                            'Profile Image: ${lead['image_path'] ?? "No"}'),
                                        Text(
                                            'State: ${lead['state'] ?? "N/A"}'),
                                        Text('City: ${lead['city'] ?? "N/A"}'),
                                        Text(
                                            'District: ${lead['district'] ?? "N/A"}'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            height: 250,
                            padding: EdgeInsets.all(10.0),
                            margin: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lead['name'] ?? "No Name",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(lead['contact_number'] ?? ""),
                                Text(lead['email'] ?? ""),
                                Text(lead['address'] ?? ""),
                                // Text(lead['whats_app'] ?? ""),
                                Text(lead['follow_up_date'] ?? ""),
                                Text(lead['location_coordinates'] ?? ""),
                                // Text(lead['location_lat'] ?? ""),
                                // Text(lead['location_log'] ?? ""),
                                // Text(lead['image_path'] ?? ""),
                                // Text(lead['state'] ?? ""),
                                // Text(lead['city'] ?? ""),
                                // Text(lead['district'] ?? ""),
                                SizedBox(height: 50),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _submitForm(lead);
                                        _deleteLead(lead['id'], false);
                                      },
                                      child: Text("Send"),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddDetailsScreen(
                                                      // lead: lead,
                                                      ),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.edit_calendar)),
                                    IconButton(
                                      onPressed: () {
                                        _deleteLead(lead['id'], true);
                                      },
                                      icon: Icon(Icons.delete),
                                      style: ElevatedButton.styleFrom(
                                        iconColor: Colors
                                            .red, // Red color for delete button
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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
              onPressed: isLoading ? null : _syncAllLeads,
              child: isLoading ? CircularProgressIndicator() : Text('Sync'),
            ),
          ),
        ],
      ),
    );
  }
}
