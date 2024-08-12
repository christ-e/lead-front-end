import 'package:contacts_service/contacts_service.dart';
import 'package:email_auth/email_auth.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:lead_application/controller/loginControler.dart';
import 'package:lead_application/controller/registarionController.dart';
import 'package:lead_application/create/login_Screen/credentils/widgets/otp_verification.dart';
import 'package:lead_application/validator/validation.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateUser extends StatefulWidget {
  @override
  _CreateUserState createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _OTP = false;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuart,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showOtpSentSnackBar() {
    _controller.forward();
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            backgroundColor: Colors.lightGreen,
            content: SlideTransition(
              position: _offsetAnimation,
              child: Text("OTP sent successfully"),
            ),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        )
        .closed
        .then((_) {
      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    LoginController loginController = Get.put(LoginController());
    loginController.emailController.clear();
    loginController.passwordController
        .clear(); // to clear textfield in login page
    RegistrationController registrationController =
        Get.put(RegistrationController());
    final TextEditingController _otpController = TextEditingController();
    OTPService otpService = OTPService();

    void sendOTP() async {
      EmailOTP.config(
        appName: 'App Name',
        otpType: OTPType.numeric,
        expiry: 30000,
        emailTheme: EmailTheme.v6,
        appEmail: 'me@rohitchouhan.com',
        otpLength: 6,
      );
    }

    Future<void> pickContact() async {
      PermissionStatus permissionStatus = await Permission.contacts.request();

      if (permissionStatus.isGranted) {
        Contact? contact = await ContactsService.openDeviceContactPicker();
        if (contact != null && contact.phones!.isNotEmpty) {
          setState(() {
            _formKey.currentState?.fields['phone']
                ?.didChange(contact.phones!.first.value);
          });
        }
      } else {
        // Handle permission denied scenario
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Contacts permission is required to pick a contact')),
        );
      }
    }

    void verifyOTP() async {
      EmailAuth emailAuth = EmailAuth(sessionName: "Test Session");
      var res = emailAuth.validateOtp(
          recipientMail: registrationController.emailController.text,
          userOtp: _otpController.text);
      if (res) {
        print("Otp Verified");
      } else {
        print("Invalid otp");
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 100),
                Text(
                  "Register",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 15),
                Text(
                  "Create your account",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 100),
                FormBuilderTextField(
                  name: 'name',
                  controller: registrationController.nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => ErrorValidation().createName(value),
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  name: 'email',
                  controller: registrationController.emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: TextButton(
                      onPressed: () {
                        setState(() async {
                          sendOTP();
                          otpService.sendOTP(registrationController
                              .emailController
                              .toString());
                          _OTP = !_OTP;
                          _showOtpSentSnackBar;
                        });
                      },
                      child: Text("Send OTP"),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => ErrorValidation().createUsername(value),
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  name: 'Otp',
                  enabled: _OTP,
                  decoration: InputDecoration(
                    labelText: 'OTP',
                    suffixIcon: TextButton(
                      child: Text("Verify OTP"),
                      onPressed: () {
                        setState(() {
                          EmailOTP.verifyOTP(otp: _otpController.text);
                        });
                      },
                    ),
                    prefixIcon: const Icon(Icons.verified_user_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // validator: (value) => ErrorValidation().createPhoneNo(value),
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  name: 'password',
                  controller: registrationController.passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.password_outlined),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: _obscurePassword
                          ? const Icon(Icons.visibility_outlined)
                          : const Icon(Icons.visibility_off_outlined),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => ErrorValidation().createPassword(value),
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  name: 'phone',
                  controller: registrationController.phoneNoController,
                  decoration: InputDecoration(
                      labelText: 'Phone No',
                      prefixIcon: const Icon(Icons.contact_phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.contacts_outlined),
                        onPressed: () {
                          pickContact();
                        },
                      )),
                  validator: (value) => ErrorValidation().createPhoneNo(value),
                ),
                const SizedBox(height: 50),
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          print("Account created");

                          registrationController.registerWithEmail(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              width: 200,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              behavior: SnackBarBehavior.floating,
                              content: const Text("Registered Successfully"),
                            ),
                          );

                          _formKey.currentState?.reset();

                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Register"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            loginController.isLoading.value = false;
                            Get.back();
                          },
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
