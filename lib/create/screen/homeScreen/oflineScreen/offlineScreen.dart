import 'package:flutter/material.dart';
import 'package:lead_application/services/database_services.dart';

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

  void _addLead(Map<String, dynamic> lead) async {
    await _databaseService.insertLead(lead);
    _fetchLeads(); // Ensure the leads are fetched again to refresh the UI
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
                            Text(lead['follow_up_date'] ??
                                "********no date*******"),
                            Text(lead['location_coordinates'] ?? ""),
                            Text(lead['location_lat'] ?? ""),
                            Text(lead['location_log'] ?? ""),
                            Text(lead['state'] ?? ""),
                            Text(lead['city'] ?? ""),
                            Text(lead['district'] ?? ""),
                          ],
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
              onPressed: () {
                // Navigator.push(
                //  context,
                // MaterialPageRoute(
                // builder: (context) => LeadFormScreen(onSubmit: _addLead)),
                // );
              },
              child: Text('Sync'),
            ),
          ),
        ],
      ),
    );
  }
}
