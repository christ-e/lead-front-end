// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lead_application/riverpod/api_functions.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsyncValue = ref.watch(leadsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('Leads List'),
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
                separatorBuilder: (context, index) => const Divider(),
                itemCount: leads.length,
                itemBuilder: (context, index) {
                  final lead = leads[index];
                  return ListTile(
                    title: Text(
                      lead.name ?? 'No Name',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
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
                    isThreeLine: true,
                    trailing: Column(
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
                        // IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
                      ],
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
