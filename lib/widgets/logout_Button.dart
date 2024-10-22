import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_application/controller/locationControler.dart';
import 'package:lead_application/db_connection/services/database_services.dart';
import 'package:lead_application/db_connection/services/location_services.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.loginController,
  });

  final loginController;

  Future<void> _checkDataAndLogout(BuildContext context) async {
    final DatabaseService _databaseService = DatabaseService.instance;
    LiveLocation liveLocation = Get.put(LiveLocation());
    LocationService locationService = LocationService();
    DatabaseHelper databaseHelper = DatabaseHelper();

    // void clearData() async {
    //   await databaseHelper.clearCoordinates();
    //   log('All coordinates cleared');
    // }

    void stopLocationUpdates(locationTimer) {
      locationTimer?.cancel();
    }

    final List<Map<String, dynamic>> leads =
        await _databaseService.getAllLeads();

    if (leads.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Unsynced Data"),
            content: Text(
                "There is data that needs to be synced. Do you want to proceed with logout?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  stopLocationUpdates(liveLocation.locationTimer);
                  log("Live Location Stoped");
                  locationService.stopLogging();
                  databaseHelper.cleartable();
                  loginController.logout(context);

                  locationService.stopLogging();
                },
                child: Text("Logout"),
              ),
            ],
          );
        },
      );
    } else {
      loginController.logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "LogOut",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 75, 75, 75),
          ),
        ),
        IconButton(
          onPressed: () {
            _checkDataAndLogout(context);
          },
          iconSize: 28,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}
