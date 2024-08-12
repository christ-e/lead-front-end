import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lead_application/controller/loginControler.dart';
import 'package:lead_application/model/leadModel.dart';

// Define the FutureProvider
final leadsProvider = FutureProvider<List<Lead>>((ref) async {
  LoginController loginController = Get.put(LoginController());

  final response = await http.get(
    Uri.parse('http://127.0.0.1:8000/api/lead'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${loginController.logtoken}',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Lead.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load leads');
  }
});
