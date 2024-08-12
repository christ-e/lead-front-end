import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_application/constant/api_Endpoints.dart';
import 'package:lead_application/create/login_Screen/credentils/login_screen.dart';
import 'package:lead_application/create/login_Screen/ui/login.dart';
import 'package:lead_application/create/screen/loginScreen/login_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RegistrationController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> registerWithEmail(context) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var url =
          Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.register);
      Map body = {
        'name': nameController.text,
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'phone': phoneNoController.text
      };

      http.Response response =
          await http.post(url, body: jsonEncode(body), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['code'] == 0) {
          // var token = json['data']['Token'];
          // final SharedPreferences? prefs = await _prefs;
          // await prefs?.setString('token', token);
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content: Text('Account Created')));
          nameController.clear();
          emailController.clear();
          passwordController.clear();
          phoneNoController.clear();
          Get.off(LoginScreen());
        } else {
          throw jsonDecode(response.body)["message"] ??
              "Unknown Error Occurred";
        }
      } else {
        throw jsonDecode(response.body)["Message"] ?? "Unknown Error Occurred";
      }
    } catch (e) {
      Get.back();
      showDialog(
          context: Get.context!,
          builder: (context) {
            return SimpleDialog(
              title: Text('Account Created '),
              contentPadding: EdgeInsets.all(20),
              children: [Text(e.toString())],
            );
          });
    }
  }
}
