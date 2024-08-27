// ignore_for_file: prefer_const_constructors, unused_result

import 'dart:convert';
import 'dart:io';

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
import 'package:lead_application/widgets/logout_Button.dart';
import 'package:lead_application/model/follow_upDateModel.dart';
import 'package:lead_application/db_connection/riverpod/api_functions.dart';
import 'package:http/http.dart' as http;
import 'package:lead_application/widgets/side_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../model/leadModel.dart';

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

  Future<Uint8List> loadNetworkImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<void> generateAndSavePdfTable(lead) async {
    final pdf = pw.Document();

    // Load image from network
    final Uint8List imageData = await loadNetworkImage(
        "${ApiEndPoints.authEndpoints.leadImage}${lead.image_path}");

    // Create PDF page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(imageData),
                  width: 100,
                  height: 100,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  lead.name!.toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              // Create table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header row
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Field',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Value',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data rows
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Email'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(lead.email.toString()),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Phone'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(lead.contactNumber.toString()),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Address'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(lead.address.toString()),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Location'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(lead.location.toString()),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('State'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(lead.state_name.toString()),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('District'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(lead.district_name.toString()),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('City'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(lead.city_name.toString()),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Priority'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(lead.priority),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Follow-Up'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(lead.followUp),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Follow-Up Date'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(lead.follow_up_date.toString()),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF file
    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/lead_data_${lead.id}.pdf");
    await file.writeAsBytes(await pdf.save());

    // Optionally share the PDF
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'lead_data_${lead.id}.pdf');
  }

  Future<void> generateAndSavePdf(List<Lead> leads) async {
    final pdf = pw.Document();

    // Load images for all leads
    final List<Uint8List?> imagesData =
        await Future.wait(leads.map((lead) async {
      if (lead.image_path != null) {
        return await loadNetworkImage(
            "${ApiEndPoints.authEndpoints.leadImage}${lead.image_path}");
      } else {
        return null;
      }
    }).toList());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: [
              'Image',
              'Name',
              'Email',
              'Phone',
              'Address',
              'Location',
              'State',
              'District',
              'City',
              'Priority',
              'Follow-Up',
              'Follow-Up Date'
            ],
            data: List<List<dynamic>>.generate(leads.length, (index) {
              final lead = leads[index];
              final imageData = imagesData[index];

              return [
                imageData != null
                    ? pw.Image(pw.MemoryImage(imageData), width: 50, height: 50)
                    : pw.Text("No Image"),
                lead.name!.toUpperCase(),
                lead.email ?? '',
                lead.contactNumber ?? '',
                lead.address ?? '',
                lead.locationCoordinates ?? '',
                lead.state_name ?? '',
                lead.district_name ?? '',
                lead.city_name ?? '',
                lead.leadPriority ?? '',
                lead.followUp ?? '',
                lead.follow_up_date ?? '',
              ];
            }),
          );
        },
      ),
    );

    // Save the PDF file to local storage
    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/leads_data.pdf");
    await file.writeAsBytes(await pdf.save());

    // Optionally share the PDF
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'leads_data.pdf');
  }

  Widget build(BuildContext context, WidgetRef ref) {
    List<FollowUp> followUpDate = [];
    final counterProvider = StateProvider<int>((ref) => 0);
    int counter = ref.watch(counterProvider); // read the state
    // ref.read(counterProvider.notifier).state++; // update the state

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
        actions: [LogoutButton(loginController: loginController)],
      ),
      drawer: SideBar(),
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
                                        IconButton(
                                          onPressed: () {
                                            generateAndSavePdf(leads);
                                          },
                                          icon: Icon(
                                              Icons.picture_as_pdf_rounded),
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
