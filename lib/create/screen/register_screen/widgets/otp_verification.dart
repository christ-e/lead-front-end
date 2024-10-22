import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lead_application/controller/registarionController.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class OTPService {
  String? _generatedOtp;
  RegistrationController registrationController =
      Get.put(RegistrationController());
  final TextEditingController _otpController = TextEditingController();

  String _generateOtp() {
    var rng = Random();
    _generatedOtp = (rng.nextInt(900000) + 100000).toString();
    return _generatedOtp.toString();
  }

  void sendOTP(String recipientEmail) async {
    String username =
        'noreply@email-otp.rohitchouhan.com'; // Your email address
    String password = 'vgk!cer8xku9BQN5nhk'; // Your email password

    final smtpServer = SmtpServer(
      'mail.rohitchouhan.com', // e.g. smtp.gmail.com
      username: username,
      password: password,
      port: 587,
      //  ssl: ,
    );

    final message = Message()
      ..from = Address(username, 'Your Name')
      ..recipients.add(recipientEmail)
      ..subject = 'Your OTP Code'
      ..text = 'Your OTP code is: ${_generateOtp()}';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
    }
  }

  bool verifyOTP(String userOtp) {
    return userOtp == _generatedOtp;
  }
}

// Usage
void sendOtpHandler(registrationController) {
  OTPService otpService = OTPService();
  otpService.sendOTP(registrationController.emailController.text);
}

void verifyOtpHandler(_otpController) {
  OTPService otpService = OTPService();
  bool isVerified = otpService.verifyOTP(_otpController.text);
  if (isVerified) {
    print("Otp Verified");
  } else {
    print("Invalid otp");
  }
}
