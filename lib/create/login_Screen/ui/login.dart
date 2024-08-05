// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:lead_application/controller/loginControler.dart';
// import 'package:lead_application/create/screen/homeScreen/widget/bottom_nav.dart';

// import 'home.dart';
// import 'signup.dart';

// class Login extends StatefulWidget {
//   const Login({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final FocusNode _focusNodePassword = FocusNode();
//   final TextEditingController _controllerEmail = TextEditingController();
//   final TextEditingController _controllerPassword = TextEditingController();
//   LoginController loginController = Get.put(LoginController());

//   bool _obscurePassword = true;
//   final Box _boxLogin = Hive.box("login");
//   final Box _boxAccounts = Hive.box("accounts");

//   @override
//   Widget build(BuildContext context) {
//     if (_boxLogin.get("loginStatus") ?? false) {
//       return Home();
//     }

//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.primaryContainer,
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(30.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 150),
//               Container(
//                 child: Image.asset("assets/images/ekatra_logo.png"),
//                 width: 250,
//                 height: 100,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 "Welcome back",
//                 style: Theme.of(context).textTheme.headlineLarge,
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "Login to your account",
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//               const SizedBox(height: 60),
//               TextFormField(
//                 controller: _controllerEmail,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   labelText: "Email",
//                   prefixIcon: const Icon(Icons.email_outlined),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onEditingComplete: () => _focusNodePassword.requestFocus(),
//                 validator: (String? value) {
//                   if (value == null || value.isEmpty) {
//                     return "Please enter email.";
//                   } else if (!_boxAccounts.containsKey(value)) {
//                     return "Email is not registered.";
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _controllerPassword,
//                 focusNode: _focusNodePassword,
//                 obscureText: _obscurePassword,
//                 keyboardType: TextInputType.visiblePassword,
//                 decoration: InputDecoration(
//                   labelText: "Password",
//                   prefixIcon: const Icon(Icons.password_outlined),
//                   suffixIcon: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                       icon: _obscurePassword
//                           ? const Icon(Icons.visibility_outlined)
//                           : const Icon(Icons.visibility_off_outlined)),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 validator: (String? value) {
//                   if (value == null || value.isEmpty) {
//                     return "Please enter password.";
//                   } else if (value != _boxAccounts.get(_controllerEmail.text)) {
//                     return "Wrong password.";
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 60),
//               Column(
//                 children: [
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size.fromHeight(50),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         loginController.isLoading.value =
//                             true; // Set loading state to true
//                         loginController.loginWithEmail(context, _formKey);
//                         _boxLogin.put("loginStatus", true);
//                         _boxLogin.put("userName", _controllerEmail.text);

//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) {
//                               return BottomNav();
//                             },
//                           ),
//                         );
//                       }
//                       // if (_formKey.currentState!.validate()) {
//                       //   loginController.isLoading.value =
//                       //       true; // Set loading state to true
//                       //   loginController.loginWithEmail(context, _formKey);
//                       //   Navigator.pushReplacement(
//                       //     context,
//                       //     MaterialPageRoute(
//                       //       builder: (context) {
//                       //         return BottomNav();
//                       //       },
//                       //     ),
//                       //   );
//                       // }
//                       if (_formKey.currentState?.validate() ?? false) {
//                         _boxLogin.put("loginStatus", true);
//                         _boxLogin.put("userName", _controllerEmail.text);
//                         loginController.loginWithEmail(context, _formKey);

//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) {
//                               return BottomNav();
//                             },
//                           ),
//                         );
//                       }
//                     },
//                     child: const Text("Login"),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Don't have an account?"),
//                       TextButton(
//                         onPressed: () {
//                           _formKey.currentState?.reset();

//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) {
//                                 return const Signup();
//                               },
//                             ),
//                           );
//                         },
//                         child: const Text("Signup"),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _focusNodePassword.dispose();
//     _controllerEmail.dispose();
//     _controllerPassword.dispose();
//     super.dispose();
//   }
// }
