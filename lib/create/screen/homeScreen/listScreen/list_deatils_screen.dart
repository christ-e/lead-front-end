// ignore_for_file: prefer_const_constructors, unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lead_application/create/screen/homeScreen/editScreen/add_deatils_screen.dart';
import 'package:lead_application/riverpod/api_functions.dart';
import 'package:http/http.dart' as http;

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  Future<void> deleteLead(
      BuildContext context, int leadId, WidgetRef ref) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/lead_data/$leadId'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lead deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      ref.refresh(leadsProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete lead'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsyncValue = ref.watch(leadsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text(
          'Leads List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              iconSize: 35,
              icon: const Row(
                children: [
                  Text(
                    "LogOut",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 75, 75, 75)),
                  ),
                  Icon(Icons.logout_rounded)
                ],
              ))
        ],
      ),
      body: leadsAsyncValue.when(
        data: (leads) => leads.isEmpty
            ? Center(child: Text('No Leads Found'))
            : ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                  thickness: 2,
                  indent: 1,
                  endIndent: 2,
                ),
                itemCount: leads.length,
                itemBuilder: (context, index) {
                  final lead = leads[index];
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListTile(
                      selectedColor: Colors.blueGrey,
                      title: Text(
                        lead.name ?? 'No Name',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'contact number :${lead.contactNumber ?? 'No Contact Number'}\n'
                                'address :${lead.address ?? 'No Address'}',
                              ),
                              lead.whatsapp == 1
                                  ? Text('whatsapp :yes')
                                  : Text('whatsapp :no'),
                              Text('state :${lead.state_name ?? 'No State'}'),
                              Text(
                                  'district :${lead.district_name ?? 'No District'}'),
                              Text('city :${lead.city_name ?? 'No City'}'),
                              Text(
                                'coordinates :${lead.locationCoordinates ?? 'No Coordinates'}',
                                style: TextStyle(
                                    wordSpacing: 2,
                                    textBaseline: TextBaseline.alphabetic),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lead Priority :${lead.leadPriority ?? 'No Priority'}',
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                'Follow up :${lead.followUp ?? 'No Follow Up'}',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddDetailsScreen(
                                            //  lead: lead,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    deleteLead(context, lead.id, ref);
                                    ref.refresh(leadsProvider);
                                  },
                                  icon: Icon(Icons.delete)),
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Something went wrong: $error'),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(leadsProvider);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
