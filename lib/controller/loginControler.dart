import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lead_application/constant/api_Endpoints.dart';
import 'package:lead_application/create/login_Screen/credentils/login_screen.dart';
import 'package:lead_application/create/screen/homeScreen/widget/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var logtoken = "".obs;
  var isLoading = false.obs;

  Future<void> loginWithEmail(BuildContext context) async {
    var headers = {'Content-Type': 'application/json'};
    try {
      var url =
          Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.login);
      print('URL: $url'); // Debug URL
      Map<String, String> body = {
        'email': emailController.text.trim(),
        'password': passwordController.text
      };
      print('Request Body: $body'); // Debug Request Body
      print('Headers: $headers'); // Debug Headers

      http.Response response =
          await http.post(url, body: jsonEncode(body), headers: headers);
      print('Response: ${response.body}'); // Debug Response

      if (response.statusCode == 200) {
        isLoading.value = true;
        Get.offAll(BottomNav());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Success')),
        );

        final json = jsonDecode(response.body);

        if (json['code'] == 0) {
          var receivedToken = json['data']['Token'];
          SharedPreferences prefs = await _prefs;
          await prefs.setString('token', receivedToken);

          logtoken.value =
              receivedToken; // Save the token in the observable variable
        } else if (json['code'] == 1) {
          throw json['message'];
        }
      } else {
        isLoading.value = false;
        throw jsonDecode(response.body)["Message"] ?? "LogIn Failed";
      }
      isLoading.value = true;
    } catch (error) {
      print('Error: $error'); // Debug Error
      isLoading.value = false;
      Get.back();
      showDialog(
          context: Get.context!,
          builder: (context) {
            return SimpleDialog(
              backgroundColor: const Color.fromARGB(255, 255, 170, 164),
              title: Text('Enter Valid Details'),
              contentPadding: EdgeInsets.all(20),
              children: [Text(error.toString())],
            );
          });
    }
  }

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('logtoken', logtoken.value);
  }

  Future<void> logout(BuildContext context) async {
    try {
      var url =
          Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.logout);
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${logtoken.value}',
      };

      http.Response response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        SharedPreferences prefs = await _prefs;
        await prefs.clear();
        logtoken.value = ""; // Clear the token from the observable variable
        Get.offAll(LoginScreen());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout Successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const LoginScreen();
            },
          ),
        );
      } else {
        throw 'Failed to logout';
      }
    } catch (error) {
      print('Logout Error: $error'); // Debug Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Failed: $error')),
      );
    }
  }
}
