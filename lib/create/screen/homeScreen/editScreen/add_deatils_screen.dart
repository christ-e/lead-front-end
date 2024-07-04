// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geolocator/geolocator.dart';

class AddDetailsScreen extends StatefulWidget {
  const AddDetailsScreen({super.key});

  @override
  State<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>(); // Changed to FormBuilderState
  String _location = '';

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      setState(() {
        _location = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, don't continue
        setState(() {
          _location = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, don't continue
      setState(() {
        _location = 'Location permissions are permanently denied';
      });
      return;
    }

    // When we reach here, permissions are granted and we can get the location
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _location = 'Lat: ${position.latitude}, Long: ${position.longitude}';
      // Update the FormBuilderTextField's value
      _formKey.currentState?.fields['Location Coordinates']
          ?.didChange(_location);
    });
    print(_location); // Print the updated location
  }

  final List<String> _states = [
    'State 1',
    'State 2',
    'State 3'
  ]; // Replace with your data
  final List<String> _districts = [
    'District 1',
    'District 2',
    'District 3'
  ]; // Replace with your data
  final List<String> _cities = [
    'City 1',
    'City 2',
    'City 3'
  ]; // Replace with your data
  final List<String> _priorities = ['Hot', 'Warm', 'Cold'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Details'),
      ),
      body: FormBuilder(
        key: _formKey, // Changed to FormBuilder
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
                  name: "Name",
                  decoration: InputDecoration(
                    icon: Icon(Icons.person, color: Colors.blue),
                    label: Text("Name"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  keyboardType: TextInputType.phone,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    // Uncomment for phone validation
                    // FormBuilderValidators.phone(context),
                  ]),
                  name: "Contact Number",
                  decoration: InputDecoration(
                    icon: Icon(Icons.phone, color: Colors.blue),
                    label: Text("Contact Number"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: FormBuilderCheckbox(
                    name: 'WhatsApp',
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
                  name: "Email",
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
                  name: "Address",
                  decoration: InputDecoration(
                    icon: Icon(Icons.home, color: Colors.blue),
                    label: Text("Address"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                FormBuilderDropdown<String>(
                  name: 'State',
                  decoration: InputDecoration(
                    icon: Icon(Icons.map, color: Colors.blue),
                    label: Text('State'),
                    border: OutlineInputBorder(),
                  ),
                  items: _states
                      .map((state) => DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          ))
                      .toList(),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 15),
                FormBuilderDropdown<String>(
                  name: 'District',
                  decoration: InputDecoration(
                    icon: Icon(Icons.map, color: Colors.blue),
                    label: Text('District'),
                    border: OutlineInputBorder(),
                  ),
                  items: _districts
                      .map((district) => DropdownMenuItem(
                            value: district,
                            child: Text(district),
                          ))
                      .toList(),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 15),
                FormBuilderDropdown<String>(
                  name: 'City',
                  decoration: InputDecoration(
                    icon: Icon(Icons.location_city, color: Colors.blue),
                    label: Text('City'),
                    border: OutlineInputBorder(),
                  ),
                  items: _cities
                      .map((city) => DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          ))
                      .toList(),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  readOnly: true,
                  keyboardType:
                      TextInputType.text, // Changed to TextInputType.text
                  initialValue: _location,
                  name: 'Location Coordinates',
                  decoration: InputDecoration(
                    icon: Icon(Icons.location_on, color: Colors.blue),
                    suffixIcon: IconButton(
                        onPressed: () {
                          _getCurrentLocation(); // Corrected to call the method
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
                  name: 'Follow Up',
                  decoration: InputDecoration(
                    icon: Icon(Icons.follow_the_signs, color: Colors.blue),
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
                  name: 'Lead Priority',
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
                    if (_formKey.currentState?.validate() ?? false) {
                      // Process the data
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')),
                      );
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
