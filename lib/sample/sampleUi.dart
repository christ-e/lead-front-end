// import 'dart:developer';
// import 'dart:math';

// import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:lead_application/create/screen/homeScreen/editScreen/add_deatils_screen.dart';
// import 'package:lead_application/create/screen/homeScreen/listScreen/list_deatils_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Animated Notch Bottom Bar',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const BottomNav(),
//     );
//   }
// }

// class BottomNav extends StatefulWidget {
//   const BottomNav({super.key});

//   @override
//   State<BottomNav> createState() => _BottomNavState();
// }

// class _BottomNavState extends State<BottomNav> {
//   /// Controller to handle PageView and also handles initial page
//   final _pageController = PageController(initialPage: 0);

//   /// Controller to handle bottom nav bar and also handles initial page
//   final NotchBottomBarController _controller =
//       NotchBottomBarController(index: 0);

//   int maxCount = 3;

//   @override
//   void dispose() {
//     _pageController.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     /// widget list
//     final List<Widget> bottomBarPages = [
//       const AddDetailsScreen(
//           // controller: (_controller),
//           ),
//       const ListScreen(),
//       const AddDetailsScreen(),
//     ];
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         children: List.generate(
//             bottomBarPages.length, (index) => bottomBarPages[index]),
//       ),
//       extendBody: false,
//       bottomNavigationBar: (bottomBarPages.length <= maxCount)
//           ? AnimatedNotchBottomBar(
//               /// Provide NotchBottomBarController
//               notchBottomBarController: _controller,
//               color: Colors.white,
//               showLabel: true,
//               textOverflow: TextOverflow.visible,
//               maxLine: 1,
//               shadowElevation: 5,
//               kBottomRadius: 28.0,

//               // notchShader: const SweepGradient(
//               //   startAngle: 0,
//               //   endAngle: pi / 2,
//               //   colors: [Colors.red, Colors.green, Colors.orange],
//               //   tileMode: TileMode.mirror,
//               // ).createShader(Rect.fromCircle(center: Offset.zero, radius: 8.0)),
//               notchColor: Colors.blueGrey,

//               /// restart app if you change removeMargins
//               removeMargins: false,
//               bottomBarWidth: 400,
//               showShadow: false,
//               durationInMilliSeconds: 300,

//               itemLabelStyle: const TextStyle(fontSize: 10),

//               elevation: 1,
//               bottomBarItems: const [
//                 BottomBarItem(
//                   inActiveItem: Icon(
//                     Icons.home_filled,
//                     color: Colors.blueGrey,
//                   ),
//                   activeItem: Icon(
//                     Icons.home_filled,
//                     color: Colors.blueAccent,
//                   ),
//                   itemLabel: 'list',
//                 ),
//                 BottomBarItem(
//                   inActiveItem: Icon(Icons.star, color: Colors.blueGrey),
//                   activeItem: Icon(
//                     Icons.star,
//                     color: Colors.blueAccent,
//                   ),
//                   itemLabel: 'Create',
//                 ),
//               ],
//               onTap: (index) {
//                 //  log('current selected index $index');
//                 _pageController.jumpToPage(index);
//               },
//               kIconSize: 24.0,
//             )
//           : null,
//     );
//   }
// }
