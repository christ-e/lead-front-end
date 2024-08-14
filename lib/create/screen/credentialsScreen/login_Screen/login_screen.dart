// ignore_for_file: prefer_const_constructors, unnecessary_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lead_application/controller/loginControler.dart';
import 'package:lead_application/create/screen/credentialsScreen/register_screen/createUser.dart';
import 'package:lead_application/validator/validation.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    LoginController loginController = Get.put(LoginController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Container(
                  width: 400,
                  height: 80,
                  child: Image.asset("assets/images/ekatra_logo.png"),
                ),
              ),
              Text(
                "Welcome back",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              Text(
                "Login to your account",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 60),
              FormBuilder(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FormBuilderTextField(
                      name: 'email',
                      controller: loginController.emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          ErrorValidation().loginUsername(value),
                    ),
                    SizedBox(height: 16.0),
                    FormBuilderTextField(
                      name: 'password',
                      controller: loginController.passwordController,
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
                                : const Icon(Icons.visibility_off_outlined)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) =>
                          ErrorValidation().loginPassword(value),
                    ),
                    SizedBox(height: 35),
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
                            if (_formKey.currentState!.saveAndValidate()) {
                              loginController.isLoading.value = true;
                              loginController.loginWithEmail(context);
                              // loginController.saveData();
                            }
                          },
                          child: Obx(() => loginController.isLoading.value
                              ? LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.black,
                                  size: 38,
                                )
                              : Text('Login')),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                _formKey.currentState?.reset();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return CreateUser();
                                    },
                                  ),
                                );
                              },
                              child: const Text("Signup"),
                            ),
                          ],
                        ),
                        // Text("Or"),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(15)),
                              width: 210,
                              height: 40,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    print("Sign In With Google");
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset("assets/images/google.png"),
                                      Text("Sign In With Google")
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
