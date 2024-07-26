import 'package:flutter/material.dart';
import 'package:lead_application/constant/api_Endpoints.dart';
import 'package:lead_application/create/screen/homeScreen/editScreen/add_deatils_screen.dart';
import 'package:lead_application/riverpod/api_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsList extends StatelessWidget {
  const DetailsList({
    Key? key,
    required this.lead,
    required this.leads,
    required this.makePhoneCall,
    required this.openWhatsApp,
    required this.deleteLead,
    required this.ref,
  }) : super(key: key);

  final lead;
  final leads;
  final makePhoneCall;
  final openWhatsApp;
  final deleteLead;
  final ref;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(
        lead.name ?? 'No Name',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Center(
            child: lead.image_path != null
                ? CircleAvatar(
                    radius: 70,
                    backgroundColor: leads.length.isOdd
                        ? Color.fromARGB(255, 234, 239, 241)
                        : Color.fromARGB(255, 192, 198, 230),
                    backgroundImage: NetworkImage(
                      "${ApiEndPoints.authEndpoints.leadImage}${lead.image_path}",
                    ),
                  )
                : CircleAvatar(
                    radius: 70,
                    foregroundColor: Colors.black,
                    backgroundColor: leads.length.isOdd
                        ? Color.fromARGB(255, 234, 239, 241)
                        : Color.fromARGB(255, 192, 198, 230),
                    child: Icon(
                      Icons.person,
                      size: 50,
                    ),
                  ),
          ),
          SizedBox(height: 10),
          Text(
            'Contact',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                '${lead.contactNumber ?? 'No Contact Number'}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Spacer(),
              IconButton(
                icon: Image.asset(
                  "assets/images/phone_icon.png",
                  scale: 17,
                ),
                onPressed: () {
                  makePhoneCall(lead.contactNumber.toString());
                },
              ),
              lead.whatsapp == 1
                  ? IconButton(
                      icon: Image.asset(
                        "assets/images/whats_app_icon.png",
                        scale: 17,
                      ),
                      onPressed: () {
                        openWhatsApp(lead.contactNumber.toString());
                      },
                    )
                  : SizedBox(),
            ],
          ),
          Text(
            'Address',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                '${lead.address ?? 'No Address'}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Email Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              lead.email != null
                  ? IconButton(
                      icon: Icon(Icons.markunread_outlined),
                      onPressed: () async {
                        final String? emailAddress = lead.address;
                        if (emailAddress != null && emailAddress.isNotEmpty) {
                          final Uri uri = Uri(
                            scheme: 'mailto',
                            path: emailAddress,
                          );
                          final String url = uri.toString();
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Could not launch email client'),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('No email address provided')),
                          );
                        }
                      },
                    )
                  : SizedBox(),
            ],
          ),
          Row(
            children: [
              lead.email != null
                  ? Text(
                      '${lead.email ?? 'No Address'}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        letterSpacing: 2,
                      ),
                    )
                  : Text("(Email Address is not given)"),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () async {
                  final String googleMapsUrl =
                      'https://www.google.com/maps/search/?api=1&query=${lead.locationCoordinates}';
                  if (await canLaunch(googleMapsUrl)) {
                    await launch(googleMapsUrl);
                  } else {
                    throw 'Could not launch $googleMapsUrl';
                  }
                },
                icon: Icon(Icons.location_on_outlined),
              ),
            ],
          ),
          Text(
            '${lead.locationCoordinates ?? 'No Coordinates'}',
            style: TextStyle(
              wordSpacing: 2,
              textBaseline: TextBaseline.alphabetic,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'State : ${lead.state_name ?? 'No State'}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(
            'District : ${lead.district_name ?? 'No District'}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(
            'City : ${lead.city_name ?? 'No City'}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Lead Priority :',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              Text(
                "${lead.leadPriority ?? 'No Priority'}",
                style: TextStyle(
                  color: lead.leadPriority == "Hot"
                      ? Color.fromARGB(255, 223, 43, 43)
                      : lead.leadPriority == "Warm"
                          ? Color.fromARGB(255, 176, 130, 77)
                          : Colors.blueAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Follow up :${lead.followUp ?? 'No Follow Up'}',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          lead.follow_up_date != null && lead.follow_up_date!.isNotEmpty
              ? Row(
                  children: [
                    Text(
                      'Follow up Date: ${lead.follow_up_date}',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        "assets/images/remider_calender_icon.png",
                        scale: 14,
                      ),
                    ),
                  ],
                )
              : SizedBox(),
          SizedBox(height: 3),
          leads.length.isOdd
              ? Divider()
              : Divider(color: Color.fromARGB(255, 177, 177, 177)),
        ],
      ),
      actions: [
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
        SizedBox(width: 40),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddDetailsScreen(lead: lead),
              ),
            );
          },
          icon: Image.asset(
            "assets/images/edit_icon.png",
            scale: 7,
          ),
        ),
        SizedBox(width: 25),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Back'),
        ),
      ],
    );
  }
}
