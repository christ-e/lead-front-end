// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddDetailsScreen extends StatefulWidget {
  const AddDetailsScreen({super.key});

  @override
  State<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String _location = '';
  String _contact = '';

  List<dynamic> _states = [];
  List<dynamic> _districts = [];
  List<dynamic> _cities = [];

  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedCity;

  final List<String> _priorities = ['Hot', 'Warm', 'Cold'];

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  Future<void> _fetchStates() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/api/states'));
    if (response.statusCode == 200) {
      setState(() {
        _states = jsonDecode(response.body);
      });
    }
  }

  Future<void> _fetchDistricts(String stateId) async {
    final response = await http
        .get(Uri.parse('http://127.0.0.1:8000/api/districts/$stateId'));
    if (response.statusCode == 200) {
      setState(() {
        _districts = jsonDecode(response.body);
        _cities = [];
        _selectedDistrict = null;
        _selectedCity = null;
      });
    }
  }

  Future<void> _fetchCities(String districtId) async {
    final response = await http
        .get(Uri.parse('http://127.0.0.1:8000/api/cities/$districtId'));
    if (response.statusCode == 200) {
      setState(() {
        _cities = jsonDecode(response.body);
        _selectedCity = null;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = 'Location permissions are permanently denied';
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _location = 'Lat: ${position.latitude}, Long: ${position.longitude}';
    });
    _formKey.currentState?.fields['location_coordinates']?.didChange(_location);
    print(_location);
  }

  Future<void> _submitForm(Map<String, dynamic> formDetails) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/store'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(formDetails),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle successful response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Optionally, navigate to another screen
    } else if (response.statusCode == 422) {
      // Handle validation error response
      final errors = jsonDecode(response.body)['errors'];
      errors.forEach((field, messages) {
        _formKey.currentState?.invalidateField(
          name: field,
          errorText: messages.join(', '),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Validation errors occurred.'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      // Handle other error responses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit form'),
          backgroundColor: Colors.red,
        ),
      );
      // Optionally, show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Details'),
      ),
      body: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                FormBuilderTextField(
                  autocorrect: true,
                  keyboardType: TextInputType.name,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  name: "name",
                  decoration: InputDecoration(
                    icon: Icon(Icons.person, color: Colors.blue),
                    label: Text("Name"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  keyboardType: TextInputType.phone,
                  initialValue: _contact,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  name: "contact_number",
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _contact = "No Contact Selected";
                          });
                        },
                        icon: Icon(Icons.contacts_rounded)),
                    icon: Icon(Icons.phone, color: Colors.blue),
                    label: Text("Contact Number"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: FormBuilderCheckbox(
                    name: 'whats_app',
                    title: Text('If this number is also a WhatsApp number'),
                    initialValue: false,
                    validator: FormBuilderValidators.compose([]),
                  ),
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  autocorrect: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.compose([]),
                  name: "email",
                  decoration: InputDecoration(
                    icon: Icon(Icons.email, color: Colors.blue),
                    label: Text("Email (Optional)"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  maxLines: 3,
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  name: "address",
                  decoration: InputDecoration(
                    icon: Icon(Icons.home, color: Colors.blue),
                    label: Text("Address"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                FormBuilderDropdown<String>(
                  name: 'state',
                  decoration: InputDecoration(
                    icon: Icon(Icons.map, color: Colors.blue),
                    labelText: 'State',
                    border: OutlineInputBorder(),
                  ),
                  items: _states.map((state) {
                    return DropdownMenuItem(
                      value: state['id'].toString(),
                      child: Text(state['state']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                      _fetchDistricts(_selectedState.toString());
                    });
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 15),
                FormBuilderDropdown<String>(
                  name: 'district',
                  decoration: InputDecoration(
                    icon: Icon(Icons.home_work_outlined, color: Colors.blue),
                    label: Text('District'),
                    border: OutlineInputBorder(),
                  ),
                  items: _districts
                      .map((district) => DropdownMenuItem(
                            value: district['id'].toString(),
                            child: Text(district['district']),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                      _fetchCities(value!);
                    });
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 15),
                FormBuilderDropdown<String>(
                  name: 'city',
                  decoration: InputDecoration(
                    icon: Icon(Icons.home_work_rounded, color: Colors.blue),
                    label: Text('City'),
                    border: OutlineInputBorder(),
                  ),
                  items: _cities
                      .map((city) => DropdownMenuItem(
                            value: city['id'].toString(),
                            child: Text(city['city']),
                          ))
                      .toList(),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  initialValue: _location,
                  name: 'location_coordinates',
                  decoration: InputDecoration(
                    icon: Icon(Icons.location_on, color: Colors.blue),
                    suffixIcon: IconButton(
                        onPressed: () {
                          _getCurrentLocation();
                        },
                        icon: Icon(Icons.gps_fixed_rounded)),
                    label: Text('Location Coordinates'),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 15),
                FormBuilderRadioGroup<String>(
                  name: 'follow_up',
                  decoration: InputDecoration(
                    icon: Icon(Icons.rate_review, color: Colors.blue),
                    label: Text('Follow Up'),
                    border: OutlineInputBorder(),
                  ),
                  options: [
                    FormBuilderFieldOption(value: 'Yes', child: Text('Yes')),
                    FormBuilderFieldOption(value: 'No', child: Text('No')),
                  ],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 15),
                FormBuilderDropdown<String>(
                  name: 'lead_priority',
                  decoration: InputDecoration(
                    icon: Icon(Icons.priority_high, color: Colors.blue),
                    label: Text('Lead Priority'),
                    border: OutlineInputBorder(),
                  ),
                  items: _priorities
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          ))
                      .toList(),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save the form state
                      _formKey.currentState!.save();

                      // Process the data
                      final formDetails = _formKey.currentState!.value;
                      print(formDetails);

                      // Submit the form details
                      _submitForm(formDetails);
                      print(jsonEncode(formDetails));
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
