// ignore_for_file: prefer_const_constructors, unused_result

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lead_application/constant/api_Endpoints.dart';
import 'package:lead_application/controller/loginControler.dart';
import 'package:lead_application/create/screen/homeScreen/editScreen/add_deatils_screen.dart';
import 'package:lead_application/create/screen/homeScreen/listScreen/widget/detais_list.dart';
import 'package:lead_application/model/follow_upDateModel.dart';
import 'package:lead_application/db_connection/riverpod/api_functions.dart';
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
      BuildContext context, int leadId, WidgetRef ref, logtoken) async {
    final response = await http.delete(
      Uri.parse(
          "${ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.deleteData}$leadId"),
      // Uri.parse('http://127.0.0.1:8000/api/lead_data/$leadId'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': ' Bearer $logtoken'
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
          content: Text('Lead deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
    // final String emailAddress = '';

    void _copyToClipboard(String? text) {
      if (text != null) {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied to clipboard')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nothing to copy')),
        );
      }
    }
  }

  Widget build(BuildContext context, WidgetRef ref) {
    List<FollowUp> followUpDate = [];

    LoginController loginController = Get.put(LoginController());
    var submitTextStyle = TextStyle(
        fontSize: 18,
        letterSpacing: 2,
        color: Colors.black,
        fontWeight: FontWeight.w400);
    Future<void> getFollowUpDates(int leadId) async {
      try {
        final response = await http.get(Uri.parse(
            '${ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.follow_upData}$leadId'));
        // .get(Uri.parse('http://127.0.0.1:8000/api/follow-ups/$leadId'));

        if (response.statusCode == 200) {
          List jsonResponse =
              json.decode(response.body); // This assumes the response is a list
          followUpDate =
              jsonResponse.map((data) => FollowUp.fromJson(data)).toList();
        } else {
          throw Exception('Failed to load follow-up dates');
        }
      } catch (e) {
        print('Error fetching follow-up dates: $e');
      }
    }

    final leadsAsyncValue = ref.watch(leadsProvider);

    return Scaffold(
      backgroundColor: leadsAsyncValue.hasValue
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.inverseSurface,

      // backgroundColor: Color.fromARGB(255, 233, 251, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 233, 251, 255),
        title: const Text(
          'Leads List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              //logout
              onPressed: () {
                loginController.logout(context);
              },
              iconSize: 35,
              icon: const Row(
                children: [
                  Text(
                    "",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 75, 75, 75)),
                  ),
                  Icon(Icons.logout_rounded),
                  SizedBox(
                    width: 10,
                  )
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
                      Image.asset("assets/images/empty_folder_icon.png"),
                      ElevatedButton(
                          onPressed: () {
                            ref.refresh(leadsProvider);
                          },
                          child: Text("Refresh")),
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
                    final colors = [
                      Color.fromARGB(255, 245, 245, 245), // Light Gray
                      Color.fromARGB(255, 255, 248, 240), // Light Beige
                      Color.fromARGB(255, 240, 255, 240), // Honeydew
                      Color.fromARGB(255, 240, 248, 255), // Alice Blue
                      Color.fromARGB(255, 255, 250, 250), // Snow
                    ];
                    final cardColor = colors[index % colors.length];
                    return Padding(
                      padding: const EdgeInsets.all(17),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: lead.leadPriority == "Hot"
                              ? Color.fromARGB(255, 223, 43, 43)
                              : lead.leadPriority == "Warm"
                                  ? Color.fromARGB(255, 255, 199, 136)
                                  : Colors.blueAccent,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: cardColor),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          lead.name ?? 'No Name',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        lead.image_path != null
                                            ? CircleAvatar(
                                                radius: 30,
                                                backgroundColor:
                                                    leads.length.isOdd
                                                        ? Color.fromARGB(
                                                            255, 234, 239, 241)
                                                        : Color.fromARGB(
                                                            255, 234, 239, 241),
                                                backgroundImage: NetworkImage(
                                                  "${ApiEndPoints.authEndpoints.leadImage}${lead.image_path}",
                                                ),
                                              )
                                            : CircleAvatar(
                                                radius: 30,
                                                foregroundColor: Colors.black,
                                                backgroundColor:
                                                    leads.length.isOdd
                                                        ? Color.fromARGB(
                                                            255, 234, 239, 241)
                                                        : Color.fromARGB(
                                                            255, 255, 255, 255),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 50,
                                                ),
                                              )
                                      ],
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
                                                  _openWhatsApp(lead
                                                      .contactNumber
                                                      .toString());
                                                },
                                              )
                                            : Text("")
                                      ],
                                    ),
                                    Text(
                                      'Location :${lead.locationCoordinates ?? 'No Coordinates'}',
                                      style: TextStyle(
                                          wordSpacing: 2,
                                          textBaseline: TextBaseline.alphabetic,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      height: 20,
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
                                        lead.leadPriority == "Hot"
                                            ? Text(
                                                "${lead.leadPriority ?? 'No Priority'}",
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 223, 43, 43),
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : lead.leadPriority == "Warm"
                                                ? Text(
                                                    "${lead.leadPriority ?? 'No Priority'}",
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 218, 172, 121),
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : Text(
                                                    "${lead.leadPriority ?? 'No Priority'}",
                                                    style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    lead.follow_up_date != null &&
                                            lead.follow_up_date!.isEmpty
                                        ? Row(
                                            children: [
                                              Text(
                                                'Follow up Date: ${lead.follow_up_date}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  await getFollowUpDates(
                                                      lead.id!);
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            "Follow-Up Dates"),
                                                        content: followUpDate
                                                                .isEmpty
                                                            ? Text(
                                                                'No follow-up dates available')
                                                            : SingleChildScrollView(
                                                                child: ListBody(
                                                                  children:
                                                                      followUpDate
                                                                          .map(
                                                                              (date) {
                                                                    return Text(
                                                                        '${1}. ${date.followUpDate.toString()}');
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                        actions: [
                                                          TextButton(
                                                            child:
                                                                Text('Close'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: Image.asset(
                                                  "assets/images/remider_calender_icon.png",
                                                  scale: 9,
                                                ),
                                              )
                                            ],
                                          )
                                        : Text(
                                            'Follow up :${lead.followUp ?? 'No Follow Up'}',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                          ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    // leads.length.isOdd
                                    //     ? Divider()
                                    //     :
                                    Divider(
                                      color: lead.leadPriority == "Hot"
                                          ? Color.fromARGB(255, 223, 43, 43)
                                          : lead.leadPriority == "Warm"
                                              ? Color.fromARGB(
                                                  255, 255, 199, 136)
                                              : Colors.blueAccent,
                                      thickness: 2,
                                      indent: 1,
                                      endIndent: 2,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            deleteLead(context, lead.id!, ref,
                                                loginController.logtoken);
                                            ref.refresh(leadsProvider);
                                          },
                                          icon: Image.asset(
                                            "assets/images/delete_icon.png",
                                            scale: 10,
                                          ),
                                        ),
                                        AnimatedButton(
                                          onPress: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    DetailsList(
                                                        lead: lead,
                                                        leads: leads,
                                                        makePhoneCall:
                                                            _makePhoneCall,
                                                        openWhatsApp:
                                                            _openWhatsApp,
                                                        deleteLead: deleteLead,
                                                        ref: ref));
                                          },
                                          width: 100,
                                          height: 40,
                                          text: 'Details',
                                          selectedText: 'Details',
                                          // isSelected: true,
                                          // isReverse: false,
                                          selectedTextColor: Colors.black,
                                          // transitionType: TransitionType
                                          //     .LEFT_BOTTOM_ROUNDER,
                                          textStyle: submitTextStyle,
                                          backgroundColor: Colors.white,
                                          borderColor: Colors.blue.shade200,
                                          borderWidth: 1,
                                          borderRadius: 10,
                                          // animatedOn: AnimatedOn.onTap,
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
