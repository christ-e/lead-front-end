// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_print, use_build_context_synchronously

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:lead_application/create/screen/homeScreen/widget/bottom_nav.dart';
// import 'package:lead_application/model/leadModel.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:contacts_service/contacts_service.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:intl/intl.dart';

// class _AddDetailsScreenState extends State<AddDetailsScreen> {
//   final _formKey = GlobalKey<FormBuilderState>();
//   String _location = '';

//   List<dynamic> _states = [];
//   List<dynamic> _districts = [];
//   List<dynamic> _cities = [];

//   String? _selectedState;
//   String? _selectedDistrict;
//   String? _selectedCity;

//   String currentAddress = 'My Location';
//   Position? currentPosition;

//   final List<String> _priorities = ['Hot', 'Warm', 'Cold'];

//   final ValueNotifier<bool> _followUpNotifier = ValueNotifier(false);

//   @override
//   void initState() {
//     super.initState();
//     _fetchStates();
//     if (widget.lead != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _initializeLeadData(widget.lead!);
//       });
//     }
//   }

//   void _initializeLeadData(Lead lead) {
//     if (!mounted) return;

//     setState(() {
//       _formKey.currentState?.patchValue({
//         'name': lead.name ?? '',
//         'contact_number': lead.contactNumber ?? '',
//         'whats_app': lead.whatsapp ?? '',
//         'email': lead.email ?? '',
//         'address': lead.address ?? '',
//         'state': lead.state_name ?? '',
//         'district': lead.district_name ?? '',
//         'city': lead.city_name ?? '',
//         'location_coordinates': lead.locationCoordinates ?? '',
//         'lead_priority': lead.leadPriority ?? '',
//         'follow_up': lead.followUp ?? false,
//         'follow_up_date': lead.follow_up_date != null
//             ? DateTime.parse(lead.follow_up_date!)
//             : null,
//       });

//       _selectedState = lead.state_name;
//       _selectedDistrict = lead.district_name;
//       _selectedCity = lead.city_name;

//       if (_selectedState != null) {
//         _fetchDistricts(_selectedState!);
//       }
//       if (_selectedDistrict != null) {
//         _fetchCities(_selectedDistrict!);
//       }
//     });
//   }

//   Future<void> _fetchStates() async {
//     final response =
//         await http.get(Uri.parse('http://127.0.0.1:8000/api/states'));
//     if (response.statusCode == 200) {
//       setState(() {
//         _states = jsonDecode(response.body);
//       });
//     }
//   }

//   Future<void> _fetchDistricts(String stateId) async {
//     final response = await http
//         .get(Uri.parse('http://127.0.0.1:8000/api/districts/$stateId'));
//     if (response.statusCode == 200) {
//       setState(() {
//         _districts = jsonDecode(response.body);
//         _cities.clear();
//         _selectedDistrict = null;
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<void> _fetchCities(String districtId) async {
//     final response = await http
//         .get(Uri.parse('http://127.0.0.1:8000/api/cities/$districtId'));
//     if (response.statusCode == 200) {
//       setState(() {
//         _cities = jsonDecode(response.body);
//         _selectedCity = null;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.lead != null ? 'Edit Lead Details' : 'Add Details'),
//       ),
//       body: FormBuilder(
//         key: _formKey,
//         child: Padding(
//           padding: const EdgeInsets.all(15),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(height: 5),
//                 FormBuilderTextField(
//                   autocorrect: true,
//                   keyboardType: TextInputType.name,
//                   validator: FormBuilderValidators.compose([
//                     FormBuilderValidators.required(),
//                     FormBuilderValidators.minLength(3),
//                   ]),
//                   name: "name",
//                   decoration: InputDecoration(
//                     icon: Icon(Icons.person, color: Colors.blue),
//                     label: Text("Name"),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 FormBuilderTextField(
//                   keyboardType: TextInputType.phone,
//                   validator: FormBuilderValidators.compose([
//                     FormBuilderValidators.required(),
//                     FormBuilderValidators.numeric(),
//                   ]),
//                   name: "contact_number",
//                   decoration: InputDecoration(
//                     suffixIcon: IconButton(
//                       onPressed: pickContact,
//                       icon: Icon(Icons.contacts_rounded),
//                     ),
//                     icon: Icon(Icons.phone, color: Colors.blue),
//                     label: Text("Contact Number"),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 50),
//                   child: FormBuilderCheckbox(
//                     name: 'whats_app',
//                     title: Text('If this number is also a WhatsApp number'),
//                     initialValue: false,
//                     validator: FormBuilderValidators.compose([]),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 FormBuilderTextField(
//                   autocorrect: true,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: FormBuilderValidators.compose([]),
//                   name: "email",
//                   decoration: InputDecoration(
//                     icon: Icon(Icons.email, color: Colors.blue),
//                     label: Text("Email (Optional)"),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 FormBuilderTextField(
//                   maxLines: 3,
//                   autocorrect: true,
//                   keyboardType: TextInputType.text,
//                   validator: FormBuilderValidators.compose([
//                     FormBuilderValidators.required(),
//                   ]),
//                   name: "address",
//                   decoration: InputDecoration(
//                     icon: Icon(Icons.home, color: Colors.blue),
//                     label: Text("Address"),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 FormBuilderDropdown<String>(
//                   name: 'state',
//                   decoration: InputDecoration(
//                     icon: Icon(Icons.map, color: Colors.blue),
//                     labelText: 'State',
//                     border: OutlineInputBorder(),
//                   ),
//                   items: _states.map((state) {
//                     return DropdownMenuItem(
//                       value: state['id'].toString(),
//                       child: Text(state['state']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedState = value;
//                       _fetchDistricts(_selectedState.toString());
//                       _districts.clear();
//                       _cities.clear();
//                     });
//                   },
//                   validator: FormBuilderValidators.compose([
//                     FormBuilderValidators.required(),
//                   ]),
//                 ),
//                 const SizedBox(height: 15),
//                 FormBuilderDropdown<String>(
//                   name: 'district',
//                   decoration: InputDecoration(
//                     icon: Icon(Icons.home_work_outlined, color: Colors.blue),
//                     label: Text('District'),
//                     border: OutlineInputBorder(),
//                   ),
//                   items: _districts.map((district) {
//                     return DropdownMenuItem(
//                       value: district['id'].toString(),
//                       child: Text(district['district']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedDistrict = value;
//                       _fetchCities(value!);
//                       _cities.clear();
//                     });
//                   },
//                   validator: FormBuilderValidators.compose([
//                     FormBuilderValidators.required(),
//                   ]),
//                 ),
//                 const SizedBox(height: 15),
//                 FormBuilderDropdown<String>(
//                   name: 'city',
//                   decoration: InputDecoration(
//                     icon: Icon(Icons.home_work_rounded, color: Colors.blue),
//                     label: Text('City'),
//                     border: OutlineInputBorder(),
//                   ),
//                   items: _cities.map((city) {
//                     return DropdownMenuItem(
//                       value: city['id'].toString(),
//                       child: Text(city['city']),
//                     );
//                   }).toList(),
//                   validator: FormBuilderValidators.compose([
//                     FormBuilderValidators.required(),
//                   ]),
//                 ),
//                 const SizedBox(height: 15),
//                 FormBuilderTextField(
//                   readOnly: true,
//                   initialValue: currentAddress,
//                   name: 'location_coordinates',
//                   decoration: InputDecoration(
//                     icon: Icon(Icons.location_on, color: Colors.blue),
//                     suffixIcon: IconButton(
//                       onPressed: () async {
//                         log(currentAddress);
//                         _getCurrentLocation();
//                         try {
//                           Position position = await _determinePosition();
//                           setState(() {
//                             currentPosition = position;
//                           });
//                           await _getAddressFromLatLng(position);
//                         } catch (e) {
//                           Fluttertoast.showToast(
//                             msg: "Error: $e",
//                             toastLength: Toast.LENGTH_LONG,
//                             gravity: ToastGravity.BOTTOM,
//                             backgroundColor: Colors.red,
//                             textColor: Colors.white,
//                           );
//                         }
//                       },
//                       icon: Icon(Icons.gps_fixed_rounded),
//                     ),
//                     label: Text('Current Location'),
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: FormBuilderValidators.compose([
//                     FormBuilderValidators.required(),
//                   ]),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(right: 60),
//                   child: Text(_location),
//                 ),
//                 const SizedBox(height: 15),
//                 FormBuilderDropdown<String>(
//                   name: 'lead_priority',
//                   decoration: InputDecoration(
//                     icon: Icon(Icons.flag, color: Colors.blue),
//                     label: Text('Lead Priority'),
//                     border: OutlineInputBorder(),
//                   ),
//                   items: _priorities.map((priority) {
//                     return DropdownMenuItem(
//                       value: priority,
//                       child: Text(priority),
//                     );
//                   }).toList(),
//                   validator: FormBuilderValidators.compose([
//                     FormBuilderValidators.required(),
//                   ]),
//                 ),
//                 const SizedBox(height: 15),
//                 ValueListenableBuilder<bool>(
//                   valueListenable: _followUpNotifier,
//                   builder: (context, followUp, _) {
//                     return Column(
//                       children: [
//                         FormBuilderCheckbox(
//                           name: 'follow_up',
//                           title: Text('Follow Up'),
//                           initialValue: false,
//                           onChanged: (value) {
//                             _followUpNotifier.value = value ?? false;
//                           },
//                         ),
//                         if (followUp)
//                           FormBuilderDateTimePicker(
//                             name: 'follow_up_date',
//                             initialValue: widget.lead?.follow_up_date != null
//                                 ? DateTime.parse(widget.lead!.follow_up_date!)
//                                 : null,
//                             inputType: InputType.date,
//                             format: DateFormat('yyyy-MM-dd'),
//                             decoration: InputDecoration(
//                               icon: Icon(Icons.calendar_today,
//                                   color: Colors.blue),
//                               label: Text('Follow Up Date'),
//                               border: OutlineInputBorder(),
//                             ),
//                             validator: FormBuilderValidators.compose([
//                               FormBuilderValidators.required(),
//                             ]),
//                           ),
//                       ],
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 15),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState?.saveAndValidate() ?? false) {
//                       // Handle form submission
//                       final formData = _formKey.currentState?.value;
//                       print(formData);
//                     }
//                   },
//                   child: Text('Submit'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> pickContact() async {
//     PermissionStatus permissionStatus = await Permission.contacts.request();

//     if (permissionStatus.isGranted) {
//       Contact? contact = await ContactsService.openDeviceContactPicker();
//       if (contact != null && contact.phones!.isNotEmpty) {
//         setState(() {
//           _formKey.currentState?.fields['contact_number']
//               ?.didChange(contact.phones!.first.value);
//         });
//       }
//     } else {
//       // Handle permission denied scenario
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text('Contacts permission is required to pick a contact')),
//       );
//     }
//   }

//   Future<void> _askPermissions(String routeName) async {
//     PermissionStatus permissionStatus = await _getContactPermission();
//     if (permissionStatus == PermissionStatus.granted) {
//       if (routeName != null) {
//         Navigator.of(context).pushNamed(routeName);
//       }
//     } else {
//       _handleInvalidPermissions(permissionStatus);
//     }
//   }

//   Future<PermissionStatus> _getContactPermission() async {
//     PermissionStatus permission = await Permission.contacts.status;
//     if (permission != PermissionStatus.granted &&
//         permission != PermissionStatus.permanentlyDenied) {
//       PermissionStatus permissionStatus = await Permission.contacts.request();
//       return permissionStatus;
//     } else {
//       return permission;
//     }
//   }

//   void _handleInvalidPermissions(PermissionStatus permissionStatus) {
//     if (permissionStatus == PermissionStatus.denied) {
//       final snackBar = SnackBar(content: Text('Access to contact data denied'));
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
//       final snackBar =
//           SnackBar(content: Text('Contact data not available on device'));
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     }
//   }

//   static Future<Position> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Fluttertoast.showToast(msg: 'Please enable Your Location Service');
//       return Future.error('Location services are disabled');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         Fluttertoast.showToast(msg: 'Location permissions are denied');
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       Fluttertoast.showToast(
//           msg:
//               'Location permissions are permanently denied, we cannot request permissions.');
//       return Future.error('Location permissions are permanently denied');
//     }

//     return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//   }

//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       setState(() {
//         _location = 'Location services are disabled.';
//       });
//       return;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         setState(() {
//           _location = 'Location permissions are denied';
//         });
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       setState(() {
//         _location = 'Location permissions are permanently denied';
//       });
//       return;
//     }

//     Position position = await Geolocator.getCurrentPosition();
//     setState(() {
//       _location = 'Lat: ${position.latitude}, Long: ${position.longitude}';
//     });
//     _formKey.currentState?.fields['location_coordinates']?.didChange(_location);
//     print(_location);
//   }

//   Future<void> _getAddressFromLatLng(Position position) async {
//     try {
//       List<Placemark> placemarks =
//           await placemarkFromCoordinates(position.latitude, position.longitude);

//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         setState(() {
//           currentAddress =
//               "${place.subLocality},${place.locality}, ${place.postalCode}, ${place.country}";
//         });

//         // Update the form field value
//         _formKey.currentState?.fields['location_coordinates']
//             ?.didChange(currentAddress);
//       } else {
//         setState(() {
//           currentAddress = "No address available";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         currentAddress = "Error retrieving address";
//       });
//     }
//   }
// }
