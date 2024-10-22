// ignore_for_file: prefer_const_constructors

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:lead_application/create/screen/login_Screen/login_screen.dart';

void main() async {
  // await _initHive();
  EmailOTP.config(
    appName: 'MyApp',
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v1,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    ));
  }
}
