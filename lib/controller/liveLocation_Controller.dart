import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lead_application/controller/loginControler.dart';
import 'package:lead_application/db_connection/services/location_services.dart';

class LiveLocationService {
  DatabaseHelper helper = DatabaseHelper();
  LoginController loginController = Get.put(LoginController());
  final String _addLocationUrl = 'http://127.0.0.1:8000/api/live-locations_add';
  final String _getLocationUrl = 'http://127.0.0.1:8000/api/live-locations';

  Future<void> addLocation(
      double longitude, double latitude, int userId, date_time) async {
    Map<String, dynamic> locationData = {
      'longitude': longitude,
      'latitude': latitude,
      'user_id': userId,
      'date_time': date_time,
    };

    final response = await http.post(
      Uri.parse(_addLocationUrl),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer ${loginController.logtoken}',
      },
      body: jsonEncode(locationData),
    );

    if (response.statusCode == 201) {
      log('Location added successfully.');
      helper.cleartable();
    } else {
      throw Exception('Failed to add location.');
    }
  }

  Future<List<dynamic>> fetchLocations() async {
    final response = await http.get(
      Uri.parse(_getLocationUrl),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer ${loginController.logtoken}',
      },
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch locations.');
    }
  }
}
