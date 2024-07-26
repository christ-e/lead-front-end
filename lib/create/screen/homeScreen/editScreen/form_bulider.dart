// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_animated_button/flutter_animated_button.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:image_picker/image_picker.dart';

// class FormBulider extends StatefulWidget {
//   const FormBulider({
//     super.key,
//     required this.lead,
//     required this.formKey,
//     required this.image,
//     required this.pickImageCamera,
//     required this.pickImageGallary,
//     required this.picker,
//     required this.submitTextStyle,
//     required this.submitForm,
//     required this.location,
//     // required this.formKey,
//   });
//   final lead;
//   final formKey;
//   final image;
//   final pickImageCamera;
//   final pickImageGallary;
//   final picker;
//   final submitTextStyle;
//   final submitForm;
//   final location;

//   @override
//   State<FormBulider> createState() => _FormBuliderState();
// }

// class _FormBuliderState extends State<FormBulider> {
//   @override
//   Widget build(BuildContext context) {
//     return FormBuilder(
//       key: widget.formKey,
//       child: Padding(
//         padding: const EdgeInsets.all(15),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 5,
//               ),
//               Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 60,
//                     backgroundImage:
//                         widget.image != null ? FileImage(widget.image!) : null,
//                     child: widget.image == null
//                         ? IconButton(
//                             onPressed: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (BuildContext context) {
//                                   return AlertDialog(
//                                     title: const Text("Add Photo"),
//                                     actions: [
//                                       IconButton(
//                                         onPressed: () {
//                                           widget.pickImageCamera();
//                                           Navigator.of(context).pop();
//                                         },
//                                         icon: const Column(
//                                           children: [
//                                             Icon(Icons.camera),
//                                             Text("Camera")
//                                           ],
//                                         ),
//                                       ),
//                                       const SizedBox(width: 5),
//                                       IconButton(
//                                         onPressed: () {
//                                           widget.pickImageGallary();
//                                           Navigator.of(context).pop();
//                                         },
//                                         icon: const Column(
//                                           children: [
//                                             Icon(Icons.image),
//                                             Text("Image")
//                                           ],
//                                         ),
//                                       ),
//                                       const SizedBox(width: 20),
//                                       IconButton(
//                                         onPressed: () async {
//                                           final pickedFile =
//                                               await picker.pickImage(
//                                                   source: ImageSource.gallery);

//                                           if (pickedFile != null) {
//                                             setState(() {
//                                               image = File(pickedFile.path);
//                                             });
//                                           } else {
//                                             print('No image selected.');
//                                           }
//                                           Navigator.of(context).pop();
//                                         },
//                                         icon: const Column(
//                                           children: [
//                                             Icon(Icons.folder_copy_rounded),
//                                             Text("Files")
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               );
//                             },
//                             icon: Icon(Icons.add_a_photo_rounded),
//                             iconSize: 30,
//                           )
//                         : null,
//                   ),
//                   if (image != null)
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       top: 100,
//                       left: 100,
//                       child: IconButton(
//                         onPressed: () {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const Text("Edit Photo"),
//                                 actions: [
//                                   IconButton(
//                                     onPressed: () {
//                                       _pickImageCamera();
//                                       Navigator.of(context).pop();
//                                     },
//                                     icon: const Column(
//                                       children: [
//                                         Icon(Icons.camera),
//                                         Text("Camera")
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(width: 5),
//                                   IconButton(
//                                     onPressed: () {
//                                       _pickImageGallary();
//                                       Navigator.of(context).pop();
//                                     },
//                                     icon: const Column(
//                                       children: [
//                                         Icon(Icons.image),
//                                         Text("Image")
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(width: 20),
//                                   IconButton(
//                                     onPressed: () async {
//                                       final pickedFile =
//                                           await _picker.pickImage(
//                                               source: ImageSource.gallery);

//                                       if (pickedFile != null) {
//                                         setState(() {
//                                           _image = File(pickedFile.path);
//                                         });
//                                       } else {
//                                         print('No image selected.');
//                                       }
//                                       Navigator.of(context).pop();
//                                     },
//                                     icon: const Column(
//                                       children: [
//                                         Icon(Icons.folder_copy_rounded),
//                                         Text("Files")
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         },
//                         icon: Icon(
//                           Icons.edit,
//                           color: Colors.black,
//                         ),
//                         color: Colors.white,
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 15,
//               ),
//               const SizedBox(height: 15),
//               FormBuilderTextField(
//                 autocorrect: true,
//                 keyboardType: TextInputType.name,
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.required(),
//                   FormBuilderValidators.minLength(3),
//                 ]),
//                 name: "name",
//                 initialValue: widget.lead?.name,
//                 decoration: InputDecoration(
//                   icon: Icon(Icons.person, color: Colors.blue),
//                   label: Text("Name"),
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               FormBuilderTextField(
//                 keyboardType: TextInputType.phone,
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.required(),
//                   FormBuilderValidators.numeric(),
//                   // FormBuilderValidators.max(12),
//                   // FormBuilderValidators.min(10),
//                 ]),
//                 name: "contact_number",
//                 initialValue: widget.lead?.contactNumber,
//                 decoration: InputDecoration(
//                   suffixIcon: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           pickContact();
//                         });
//                       },
//                       icon: Icon(Icons.contacts_rounded)),
//                   icon: Icon(Icons.phone, color: Colors.blue),
//                   label: Text("Contact Number"),
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Padding(
//                 padding: const EdgeInsets.only(left: 50),
//                 child: FormBuilderCheckbox(
//                   name: 'whats_app',
//                   title: Text('If this number is also a WhatsApp number'),
//                   initialValue: widget.lead?.whatsapp == 1,
//                   validator: FormBuilderValidators.compose([]),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               FormBuilderTextField(
//                 autocorrect: true,
//                 keyboardType: TextInputType.emailAddress,
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.email(),
//                 ]),
//                 name: "email",
//                 initialValue: widget.lead?.email,
//                 decoration: InputDecoration(
//                   icon: Icon(Icons.email, color: Colors.blue),
//                   label: Text("Email (Optional)"),
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               FormBuilderTextField(
//                 maxLines: 3,
//                 autocorrect: true,
//                 keyboardType: TextInputType.text,
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.required(),
//                 ]),
//                 name: "address",
//                 initialValue: widget.lead?.address,
//                 decoration: InputDecoration(
//                   icon: Icon(Icons.home, color: Colors.blue),
//                   label: Text("Address"),
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               FormBuilderDropdown<String>(
//                 name: 'state',
//                 // initialValue: widget.lead?.state_id,
//                 decoration: InputDecoration(
//                   icon: Icon(Icons.map, color: Colors.blue),
//                   labelText: 'State',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: _states.map((state) {
//                   return DropdownMenuItem(
//                     value: state['id'].toString(),
//                     child: Text(state['state']),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedState = value;
//                     _fetchDistricts(_selectedState.toString());
//                     _districts.clear();
//                     _cities.clear();
//                   });
//                 },
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.required(),
//                 ]),
//               ),
//               const SizedBox(height: 15),
//               FormBuilderDropdown<String>(
//                 name: 'district',
//                 //initialValue: widget.lead?.district_id,
//                 decoration: InputDecoration(
//                   icon: Icon(Icons.home_work_outlined, color: Colors.blue),
//                   label: Text('District'),
//                   border: OutlineInputBorder(),
//                 ),
//                 items: _districts
//                     .map((district) => DropdownMenuItem(
//                           value: district['id'].toString(),
//                           child: Text(district['district']),
//                         ))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedDistrict = value;
//                     _fetchCities(value!);
//                     _cities.clear();
//                   });
//                 },
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.required(),
//                 ]),
//               ),
//               const SizedBox(height: 15),
//               FormBuilderDropdown<String>(
//                 name: 'city',
//                 // initialValue: widget.lead?.city_id,
//                 decoration: InputDecoration(
//                   icon: Icon(Icons.home_work_rounded, color: Colors.blue),
//                   label: Text('City'),
//                   border: OutlineInputBorder(),
//                 ),
//                 items: _cities
//                     .map((city) => DropdownMenuItem(
//                           value: city['id'].toString(),
//                           child: Text(city['city']),
//                         ))
//                     .toList(),
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.required(),
//                 ]),
//               ),
//               const SizedBox(height: 15),
//               FormBuilderTextField(
//                 readOnly: true,
//                 name: 'location_coordinates',
//                 //  initialValue: widget.lead?.locationCoordinates,
//                 initialValue: widget.lead?.locationCoordinates,
//                 decoration: InputDecoration(
//                   icon: Icon(Icons.location_on, color: Colors.blue),
//                   suffixIcon: IconButton(
//                       onPressed: () async {
//                         log(_location);
//                         //log(currentPosition.toString());
//                         print(currentAddress);
//                         _getCurrentLocation();
//                         try {
//                           Position position = await _determinePosition();
//                           setState(() {
//                             currentPosition = position;
//                           });
//                           await _getAddressFromLatLng(position);
//                         } catch (e) {
//                           Fluttertoast.showToast(
//                               msg: "Error: $e",
//                               toastLength: Toast.LENGTH_LONG,
//                               gravity: ToastGravity.BOTTOM,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white);
//                         }
//                       },
//                       icon: Icon(Icons.gps_fixed_rounded)),
//                   label: Text('Current Location'),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.required(),
//                 ]),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(right: 60),
//                 child: Text(_location),
//               ),
//               const SizedBox(height: 15),
//               FormBuilderDropdown<String>(
//                 name: 'lead_priority',
//                 initialValue: widget.lead?.leadPriority,
//                 decoration: InputDecoration(
//                   icon: Icon(Icons.priority_high, color: Colors.blue),
//                   label: Text('Lead Priority'),
//                   border: OutlineInputBorder(),
//                 ),
//                 items: _priorities
//                     .map((priority) => DropdownMenuItem(
//                           value: priority,
//                           child: Text(priority),
//                         ))
//                     .toList(),
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.required(),
//                 ]),
//               ),
//               const SizedBox(height: 20),
//               FormBuilderRadioGroup<String>(
//                 name: 'follow_up',
//                 initialValue: widget.lead?.followUp,
//                 separator: SizedBox(width: 20),
//                 decoration: InputDecoration(
//                   icon: Icon(Icons.rate_review, color: Colors.blue),
//                   label: Text('Follow Up'),
//                   border: OutlineInputBorder(borderSide: BorderSide.none),
//                 ),
//                 options: [
//                   FormBuilderFieldOption(value: 'Yes', child: Text('Yes')),
//                   FormBuilderFieldOption(value: 'No', child: Text('No')),
//                 ],
//                 validator: FormBuilderValidators.compose([
//                   FormBuilderValidators.required(),
//                 ]),
//                 onChanged: (value) {
//                   _followUpNotifier.value = value == 'Yes';
//                 },
//               ),
//               const SizedBox(height: 20),
//               ValueListenableBuilder<bool>(
//                 valueListenable: _followUpNotifier,
//                 builder: (context, followUpEnabled, child) {
//                   return FormBuilderDateTimePicker(
//                     name: 'follow_up_date',
//                     //  initialDate:widget.lead?.follow_up_date,

//                     inputType: InputType.date,
//                     format: DateFormat('dd-MM-yyyy'),
//                     decoration: InputDecoration(
//                       labelText: 'Select Date',
//                       icon: Icon(Icons.calendar_today, color: Colors.blue),
//                       border: OutlineInputBorder(),
//                     ),
//                     enabled: followUpEnabled,
//                     validator: followUpEnabled
//                         ? FormBuilderValidators.compose([
//                             FormBuilderValidators.required(),
//                           ])
//                         : null,
//                   );
//                 },
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   AnimatedButton(
//                     onPress: () {
//                       setState(() {
//                         _formKey.currentState!.reset();
//                         _formKey.currentState!.fields["state"]!.didChange(null);
//                         _formKey.currentState!.fields["lead_priority"]!
//                             .didChange(null);
//                         _formKey.currentState!.fields["follow_up"]!
//                             .didChange(null);
//                         _formKey.currentState!.fields["follow_up_date"]!
//                             .didChange(null);
//                       });
//                     },
//                     width: 120,
//                     height: 50,
//                     text: 'CLEAR',
//                     isReverse: true,
//                     selectedTextColor: Colors.lightBlue.shade200,
//                     transitionType: TransitionType.TOP_CENTER_ROUNDER,
//                     textStyle: submitTextStyle,
//                     backgroundColor: Colors.blue.shade200,
//                     borderColor: Colors.white,
//                     borderWidth: 1,
//                     borderRadius: 10,
//                     animatedOn: AnimatedOn.onTap,
//                   ),
//                   AnimatedButton(
//                     onPress: () {
//                       setState(() {
//                         if (_formKey.currentState!.validate()) {
//                           _formKey.currentState!.save();
//                           final formKey = _formKey.currentState!.value;

//                           if (widget.lead != null) {
//                             _updateForm(formKey);
//                           } else {
//                             log(formKey.toString());
//                             _submitForm(formKey, _location);
//                           }
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text('Failed to submit form'),
//                               backgroundColor: Colors.red,
//                             ),
//                           );
//                           print("Failed");
//                         }
//                       });
//                     },
//                     width: 120, // Adjusted width
//                     height: 50,
//                     text: widget.lead != null ? 'UPDATE' : 'SUBMIT',
//                     isReverse: true,
//                     selectedTextColor: Colors.black,
//                     transitionType: TransitionType.TOP_CENTER_ROUNDER,
//                     textStyle: submitTextStyle,
//                     backgroundColor: Colors.blue.shade200,
//                     borderColor: Colors.white,
//                     borderWidth: 1,
//                     borderRadius: 10,
//                     animatedOn: AnimatedOn.onHover,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
