// ignore_for_file: prefer_const_constructors, unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lead_application/create/screen/homeScreen/editScreen/add_deatils_screen.dart';
import 'package:lead_application/riverpod/api_functions.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});
  void _openWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: phoneNumber,
      queryParameters: {'text': 'Hello'},
    );

    if (await canLaunch(whatsappUri.toString())) {
      await launch(whatsappUri.toString());
    } else {
      throw 'Could not launch $whatsappUri';
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }

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

  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsyncValue = ref.watch(leadsProvider);
    //ref.refresh(leadsProvider);

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 251, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 233, 251, 255),
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
        data: (leads) => RefreshIndicator(
          onRefresh: () async {
            ref.refresh(leadsProvider);
          },
          child: leads.isEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(leadsProvider);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Text(
                        'No Leads Found',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      )),
                      Image.asset("assets/images/empty_folder_icon.png")
                    ],
                  ),
                )
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
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          // image: DecorationImage(
                          //   image: AssetImage(
                          //     "assets/images/Gradiant_bg_image.jpg",
                          //   ),
                          //   fit: BoxFit.cover,
                          // ),
                          borderRadius: BorderRadius.circular(20),
                          color: leads.length.isOdd
                              ? Color.fromARGB(255, 234, 239, 241)
                              : Color.fromARGB(255, 192, 198, 230),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  lead.name ?? 'No Name',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Contact number :${lead.contactNumber ?? 'No Contact Number'}',
                                      style: TextStyle(
                                          fontSize: 15,
                                          //letterSpacing: 1,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Spacer(),
                                    IconButton(
                                      icon: Image.asset(
                                        "assets/images/phone_icon.png",
                                        scale: 17,
                                      ),
                                      onPressed: () {
                                        _makePhoneCall(
                                            lead.contactNumber.toString());
                                      },
                                    ),
                                    lead.whatsapp == 1
                                        ? IconButton(
                                            icon: Image.asset(
                                              "assets/images/whats_app_icon.png",
                                              scale: 17,
                                            ),
                                            onPressed: () {
                                              _openWhatsApp(lead.contactNumber
                                                  .toString());
                                            },
                                          )
                                        : Text("")
                                  ],
                                ),
                                Text(
                                  'Address :${lead.address ?? 'No Address'}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      letterSpacing: 2),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                lead.email != null
                                    ? Text(
                                        'Email :${lead.email ?? 'No Address'}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            overflow: TextOverflow.ellipsis,
                                            letterSpacing: 2),
                                      )
                                    : Text("(Email Address is not given)"),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Location :${lead.locationCoordinates ?? 'No Coordinates'}',
                                  style: TextStyle(
                                      wordSpacing: 2,
                                      textBaseline: TextBaseline.alphabetic,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'State :${lead.state_name ?? 'No State'}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'District :${lead.district_name ?? 'No District'}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'City :${lead.city_name ?? 'No City'}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Lead Priority :',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (lead.leadPriority == "Hot")
                                      Text(
                                        "${lead.leadPriority ?? 'No Priority'}",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 223, 43, 43),
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    else if (lead.leadPriority == "Warm")
                                      Text(
                                        "${lead.leadPriority ?? 'No Priority'}",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 176, 130, 77),
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    else
                                      Text(
                                        "${lead.leadPriority ?? 'No Priority'}",
                                        style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Follow up :${lead.followUp ?? 'No Follow Up'}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                lead.follow_up_date != null &&
                                        lead.follow_up_date!.isNotEmpty
                                    ? Row(
                                        children: [
                                          Text(
                                            'Follow up Date: ${lead.follow_up_date}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          // SizedBox(
                                          //   width: 8,
                                          // ),
                                          IconButton(
                                            onPressed: () {},
                                            icon: Image.asset(
                                              "assets/images/remider_calender_icon.png",
                                              scale: 14,
                                            ),
                                          )
                                        ],
                                      )
                                    : Container(),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        deleteLead(context, lead.id, ref);
                                        ref.refresh(leadsProvider);
                                      },
                                      icon: Image.asset(
                                        "assets/images/delete_icon.png",
                                        scale: 10,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddDetailsScreen(
                                              lead: lead,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Image.asset(
                                        "assets/images/edit_icon.png",
                                        scale: 7,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
