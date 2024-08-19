import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lead_application/constant/api_Endpoints.dart';
import 'package:lead_application/create/screen/credentialsScreen/login_Screen/login_screen.dart';
import 'package:lead_application/widgets/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var logtoken = "";
  var userid = "";
  var username = "";

  var isLoading = false.obs;

  Future<void> loginWithEmail(
    BuildContext context,
  ) async {
    var headers = {'Content-Type': 'application/json'};
    var url =
        Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.login);
    Map body = {
      'email': emailController.text.trim(),
      'password': passwordController.text
    };

    http.Response response =
        await http.post(url, body: jsonEncode(body), headers: headers);
    print(response.body);

    if (response.statusCode == 200) {
      isLoading.value = true;

      final data = jsonDecode(response.body);
      final token = data['token'];
      print('Decoded data: $data');
      if (token != null) {
        logtoken = token;
        await saveData();

        if (data.containsKey("0") && data["0"].containsKey("id")) {
          final userId = data["0"]["id"];
          username = data["0"]["name"];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId);
          log('User ID stored: $userId');
        } else {
          print('User ID not found in response data');
        }

        log('Login successful, token stored: $logtoken');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Success')),
        );
        Get.off(BottomNav());
      } else {
        print('Token not found in response data');
      }
    } else {
      isLoading.value = false;
      print('Login failed: ${response.body}');
    }
    isLoading.value = false;
  }

  saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('logtoken', logtoken);
  }

  //logout
  Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.logout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $logtoken',
      },
    );

    if (response.statusCode == 200) {
      await prefs.clear();

      logtoken = "";
      // emailController.clear();
      passwordController.clear();
      isLoading.value = false;
      Get.offAll(() => LoginScreen());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Successful')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Failed: ${response.body}')),
      );
    }
  }
}
