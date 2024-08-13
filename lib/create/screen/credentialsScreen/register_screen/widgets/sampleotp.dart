import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';

void main() {
  EmailOTP.config(
    appName: 'MyApp',
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v2,
  );

  // EmailOTP.setSMTP(
  //   host: 'mail.rohitchouhan.com',
  //   emailPort: EmailPort.port587,
  //   secureType: SecureType.tls,
  //   username: 'noreply@email-otp.rohitchouhan.com',
  //   password: 'vgk!cer8xku9BQN5nhk',
  // );

/*
  EmailOTP.setTemplate(
    template: '''
    <div style="background-color: #f4f4f4; padding: 20px; font-family: Arial, sans-serif;">
      <div style="background-color: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
        <h1 style="color: #333;">{{appName}}</h1>
        <p style="color: #333;">Your OTP is <strong>{{otp}}</strong></p>
        <p style="color: #333;">This OTP is valid for 5 minutes.</p>
        <p style="color: #333;">Thank you for using our service.</p>
      </div>
    </div>
    ''',
  );
*/
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController otpController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Email OTP')),
      body: ListView(
        children: [
          TextFormField(controller: emailController),
          ElevatedButton(
            onPressed: () async {
              if (await EmailOTP.sendOTP(email: emailController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("OTP has been sent")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("OTP failed sent")));
              }
            },
            child: const Text('Send OTP'),
          ),
          TextFormField(controller: otpController),
          ElevatedButton(
            onPressed: () => EmailOTP.verifyOTP(otp: otpController.text),
            child: const Text('Verify OTP'),
          ),
        ],
      ),
    );
  }
}
