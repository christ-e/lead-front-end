// import 'package:flutter/material.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:lead_application/create/screen/homeScreen/widget/bottom_nav.dart';
// import 'package:lead_application/riverpod/api_functions.dart';
// import 'package:lead_application/riverpod/models/lead.dart';

// class AddDetailsScreen extends StatefulWidget {
//   final Lead? lead; //add

//   const AddDetailsScreen({super.key, this.lead}); //add

//   @override
//   State<AddDetailsScreen> createState() => _AddDetailsScreenState();
// }

// class _AddDetailsScreenState extends State<AddDetailsScreen> {
//   final _formKey = GlobalKey<FormBuilderState>();
//   String _location = '';
//   String _contact = '';

//   List<dynamic> _states = [];
//   List<dynamic> _districts = [];
//   List<dynamic> _cities = [];

//   String? _selectedState;
//   String? _selectedDistrict;
//   String? _selectedCity;

//   final List<String> _priorities = ['Hot', 'Warm', 'Cold'];

//   @override
//   void initState() {
//     super.initState();
//     _fetchStates();
//     if (widget.lead != null) {
//       //add
//       _initializeLeadData(widget.lead!); //add
//     }
//   }

//   void _initializeLeadData(Lead lead) {
//     //add
//     setState(() {
//       _contact = lead.contactNumber ?? '';
//       _location = lead.locationCoordinates ?? '';
//       _selectedState = lead.state_name ?? '';
//       _selectedDistrict = lead.district_name ?? '';
//       _selectedCity = lead.city_name ?? '';
//       _fetchDistricts(_selectedState!);
//       _fetchCities(_selectedDistrict!);
//     });
//   }

//   Future<void> _submitForm(Map<String, dynamic> formDetails) async {
//     //add
//     final response = widget.lead == null
//         ? await http.post(
//             Uri.parse('http://127.0.0.1:8000/api/store'),
//             headers: {
//               'Accept': 'application/json',
//               'Content-Type': 'application/json',
//             },
//             body: jsonEncode(formDetails),
//           )
//         : await http.put(
//             Uri.parse('http://127.0.0.1:8000/api/lead_data/${widget.lead!.id}'),
//             headers: {
//               'Accept': 'application/json',
//               'Content-Type': 'application/json',
//             },
//             body: jsonEncode(formDetails),
//           );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               'Lead ${widget.lead == null ? 'added' : 'updated'} successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       Navigator.of(context).pop();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content:
//               Text('Failed to ${widget.lead == null ? 'add' : 'update'} lead'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 214, 214, 214),
//       appBar: AppBar(
//         title: Text(widget.lead == null ? 'Add Lead' : 'Edit Lead'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: FormBuilder(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: <Widget>[
//                 FormBuilderTextField(
//                   name: 'name',
//                   initialValue: widget.lead?.name ?? '',
//                   decoration: InputDecoration(labelText: 'Name'),
//                   validator: FormBuilderValidators.compose(
//                     [
//                       FormBuilderValidators.required(),
//                       FormBuilderValidators.minLength(3)
//                     ],
//                   ),
//                 ),
//                 FormBuilderTextField(
//                   name: 'contact_number',
//                   initialValue: widget.lead?.contactNumber ?? '',
//                   decoration: InputDecoration(labelText: 'Contact Number'),
//                   keyboardType: TextInputType.phone,
//                   validator: FormBuilderValidators.compose(
//                     [
//                       FormBuilderValidators.required(),
//                       FormBuilderValidators.numeric()
//                     ],
//                   ),
//                 ),
//                 FormBuilderTextField(
//                   name: 'email_address',
//                   initialValue: widget.lead?.emailAddress ?? '',
//                   decoration: InputDecoration(labelText: 'Email Address'),
//                   validator: FormBuilderValidators.compose(
//                     [
//                       FormBuilderValidators.required(),
//                       FormBuilderValidators.email()
//                     ],
//                   ),
//                 ),
//                 FormBuilderTextField(
//                   name: 'address',
//                   initialValue: widget.lead?.address ?? '',
//                   decoration: InputDecoration(labelText: 'Address'),
//                 ),
//                 FormBuilderDropdown<String>(
//                   name: 'state',
//                   initialValue: widget.lead?.state_name ?? '',
//                   decoration: InputDecoration(labelText: 'State'),
//                   items: _states.map<DropdownMenuItem<String>>((state) {
//                     return DropdownMenuItem<String>(
//                       value: state['id'].toString(),
//                       child: Text(state['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     if (value != null) {
//                       _fetchDistricts(value);
//                       setState(() {
//                         _selectedState = value;
//                         _selectedDistrict = null;
//                         _selectedCity = null;
//                       });
//                     }
//                   },
//                 ),
//                 FormBuilderDropdown<String>(
//                   name: 'district',
//                   initialValue: widget.lead?.district_name ?? '',
//                   decoration: InputDecoration(labelText: 'District'),
//                   items: _districts.map<DropdownMenuItem<String>>((district) {
//                     return DropdownMenuItem<String>(
//                       value: district['id'].toString(),
//                       child: Text(district['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     if (value != null) {
//                       _fetchCities(value);
//                       setState(() {
//                         _selectedDistrict = value;
//                         _selectedCity = null;
//                       });
//                     }
//                   },
//                 ),
//                 FormBuilderDropdown<String>(
//                   name: 'city',
//                   initialValue: widget.lead?.city_name ?? '',
//                   decoration: InputDecoration(labelText: 'City'),
//                   items: _cities.map<DropdownMenuItem<String>>((city) {
//                     return DropdownMenuItem<String>(
//                       value: city['id'].toString(),
//                       child: Text(city['name']),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCity = value;
//                     });
//                   },
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     TextButton.icon(
//                       onPressed: _getCurrentLocation,
//                       icon: Icon(Icons.location_on_outlined),
//                       label: Text('Get Current Location'),
//                     ),
//                     Expanded(
//                       child: FormBuilderTextField(
//                         name: 'location_coordinates',
//                         initialValue: _location,
//                         decoration:
//                             InputDecoration(labelText: 'Location Coordinates'),
//                         readOnly: true,
//                       ),
//                     ),
//                   ],
//                 ),
//                 FormBuilderDropdown<String>(
//                   name: 'lead_priority',
//                   initialValue: widget.lead?.leadPriority ?? '',
//                   decoration: InputDecoration(labelText: 'Lead Priority'),
//                   items: _priorities.map((priority) {
//                     return DropdownMenuItem(
//                       value: priority,
//                       child: Text(priority),
//                     );
//                   }).toList(),
//                 ),
//                 FormBuilderDropdown<int>(
//                   name: 'follow_up',
//                   initialValue: widget.lead?.followUp == 'yes' ? 1 : 0,
//                   decoration: InputDecoration(labelText: 'Follow Up'),
//                   items: [
//                     DropdownMenuItem(
//                       value: 1,
//                       child: Text('Yes'),
//                     ),
//                     DropdownMenuItem(
//                       value: 0,
//                       child: Text('No'),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState?.saveAndValidate() ?? false) {
//                       final formDetails = {
//                         'name': _formKey.currentState?.fields['name']?.value,
//                         'contact_number': _formKey
//                             .currentState?.fields['contact_number']?.value,
//                         'email_address': _formKey
//                             .currentState?.fields['email_address']?.value,
//                         'address':
//                             _formKey.currentState?.fields['address']?.value,
//                         'state': _selectedState,
//                         'district': _selectedDistrict,
//                         'city': _selectedCity,
//                         'location_coordinates': _formKey.currentState
//                             ?.fields['location_coordinates']?.value,
//                         'lead_priority': _formKey
//                             .currentState?.fields['lead_priority']?.value,
//                         'follow_up':
//                             _formKey.currentState?.fields['follow_up']?.value ==
//                                     1
//                                 ? 'yes'
//                                 : 'no',
//                       };
//                       _submitForm(formDetails);
//                     }
//                   },
//                   child: Text(widget.lead == null ? 'Submit' : 'Update'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
