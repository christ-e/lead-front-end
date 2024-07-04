// // ignore_for_file: unnecessary_nullable_for_final_variable_declarations, prefer_const_constructors, no_leading_underscores_for_local_identifiers, avoid_print, file_names

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:sample_project1/screens/homescreen/homescreen.dart';
// import 'package:sample_project1/screens/login/login_screen.dart';
// import 'package:sample_project1/utils/api_endpoints.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginController extends GetxController {
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//   var logtoken = "";
//   var isLoading = false.obs;
//   Future<void> loginWithEmail(context, _formKey) async {
//     var headers = {'Content-Type': 'application/json'};
//     try {
//       var url =
//           Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.login);
//       Map body = {
//         'email': emailController.text.trim(),
//         'password': passwordController.text
//       };
//       http.Response response =
//           await http.post(url, body: jsonEncode(body), headers: headers);
//       print(response.body);
//       // logtoken = response.body;

//       if (response.statusCode == 200) {
//         isLoading.value = true;
//         Get.off(MyHomePage());

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Login Success')), //meassage
//         );
//         final json = jsonDecode(response.body);

//         final token = json['token'];
//         if (json['code'] == 0) {
//           var receivedToken = json['data']['Token'];
//           final SharedPreferences? logtoken = await _prefs;
//           token?.setString(
//               "token", receivedToken); //save token in shared preference

//           final SharedPreferences? prefs = await _prefs;
//           await prefs?.setString('token', logtoken as String);
//         } else if (json['code'] == 1) {
//           throw jsonDecode(response.body)['message'];
//         }
//       } else {
//         isLoading.value = false;
//         throw jsonDecode(response.body)["Message"] ?? "LogIn Failed ";
//       }
//       isLoading.value = true;
//     } catch (error) {
//       Get.back();
//       showDialog(
//           context: Get.context!,
//           builder: (context) {
//             return SimpleDialog(
//               backgroundColor: const Color.fromARGB(255, 255, 170, 164),
//               title: Text('Enter Valid  Details'),
//               contentPadding: EdgeInsets.all(20),
//               children: [Text(error.toString())],
//             );
//           });
//     }
//   }

//   void saveData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('logtoken', logtoken);
//   }

//   //logout
//   Future<void> logout(context) async {
//     final SharedPreferences? prefs = await _prefs;
//     prefs?.clear();
//     // logIntoken.value = ""; // Clear the token on logout
//     Get.offAll(LoginScreen());
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Logout Successful')),
//     );
//   }
// }
