//  floatingActionButton: FloatingActionButton(
//         onPressed: _showOptions,
//         backgroundColor: Colors.white,
//         child: Icon(Icons.more_vert),
//       ),
//   void _showOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Padding(
//           padding: const EdgeInsets.only(
//             top: 30,
//             right: 100,
//             left: 100,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   // Handle "Warm" option here
//                 },
//                 child: Text('Warm'),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   // Handle "Hot" option here
//                 },
//                 child: Text('Hot'),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   // Handle "Cold" option here
//                 },
//                 child: Text('Cold'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }