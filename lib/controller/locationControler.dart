import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:lead_application/controller/liveLocation_Controller.dart';
import 'package:lead_application/controller/loginControler.dart';
import 'package:lead_application/db_connection/services/location_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveLocation extends GetxController {
  final LoginController loginController = Get.put(LoginController());

  final LiveLocationService _liveLocationService = LiveLocationService();
  Timer? locationTimer;
  Future<void> addLocation() async {
    final userid = await SharedPreferences.getInstance();
    final userId = userid.getInt('userId');

    try {
      List<Map<String, dynamic>> coordinates =
          await DatabaseHelper.fetchCoordinates();

      for (var coordinate in coordinates) {
        double latitude = coordinate['latitude'];
        double longitude = coordinate['longitude'];
        String date_time = coordinate['timestamp'];

        await _liveLocationService.addLocation(
            longitude, latitude, userId ?? 0, date_time);
      }

      log('All locations added to Back-end.');
    } catch (e) {
      log('Error adding location: $e');
    }
  }
}
