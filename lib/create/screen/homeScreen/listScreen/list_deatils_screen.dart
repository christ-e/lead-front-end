// import 'package:flutter/material.dart';

// class ListScreen extends StatelessWidget {
//   const ListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Account Screen'),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lead_application/model/leadModel.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<Lead>> futureLeads;

  Future<List<Lead>> fetchLeads() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/api/lead'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Lead.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load leads');
    }
  }

  @override
  void initState() {
    super.initState();
    futureLeads = fetchLeads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('Leads List'),
      ),
      body: FutureBuilder<List<Lead>>(
        future: futureLeads,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Leads Found'));
          } else {
            final leads = snapshot.data!;
            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: leads.length,
              itemBuilder: (context, index) {
                final lead = leads[index];
                return ListTile(
                  title: Text(
                    lead.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${lead.contactNumber}\n${lead.address}'),
                      Text(lead.state),
                      Text(lead.district),
                      Text(lead.city),
                      Text(lead.locationCoordinates),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    children: [
                      Text(lead.leadPriority),
                      Text(lead.followUp),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
