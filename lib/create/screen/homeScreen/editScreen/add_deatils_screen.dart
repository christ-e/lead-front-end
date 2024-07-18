// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_print, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lead_application/constant/api_Endpoints.dart';
import 'package:lead_application/create/screen/homeScreen/editScreen/image_picker.dart';
import 'package:lead_application/create/screen/homeScreen/widget/bottom_nav.dart';
import 'package:lead_application/model/leadModel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

class AddDetailsScreen extends StatefulWidget {
  final Lead? lead; //add

  const AddDetailsScreen({super.key, this.lead}); //add

  @override
  State<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String _location = '';

  List<dynamic> _states = [];
  List<dynamic> _districts = [];
  List<dynamic> _cities = [];

  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedCity;

  String currentAddress = 'My Location';
  Position? currentPosition;

  final List<String> _priorities = ['Hot', 'Warm', 'Cold'];

  final ValueNotifier<bool> _followUpNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _fetchStates();
    if (widget.lead != null) {
      _initializeLeadData(widget.lead!);
    }
  }

  void _initializeLeadData(Lead lead) {
    setState(() {
      _formKey.currentState?.patchValue({
        'name': lead.name ?? '',
        'contact_number': lead.contactNumber ?? '',
        'whats_app': lead.whatsapp ?? '',
        'email': lead.email ?? '',
        'address': lead.address ?? '',
        'state': lead.state_name ?? '',
        'district': lead.district_name ?? '',
        'city': lead.city_name ?? '',
        'location_coordinates': lead.locationCoordinates ?? '',
        'lead_priority': lead.leadPriority ?? '',
        'follow_up': lead.followUp ?? false,
        'follow_up_date': lead.follow_up_date != null
            ? DateTime.parse(lead.follow_up_date!)
            : null,
      });

      _selectedState = lead.state_name;
      _selectedDistrict = lead.district_name;
      _selectedCity = lead.city_name;

      if (_selectedState != null) {
        _fetchDistricts(_selectedState!);
      }
      if (_selectedDistrict != null) {
        _fetchCities(_selectedDistrict!);
      }
    });
  }

  // Future<void> _submitForm(Map<String, dynamic> formDetails) async {
  //   Map<String, dynamic> encodableFormDetails = formDetails.map((key, value) {
  //     if (value is DateTime) {
  //       return MapEntry(key, value.toIso8601String());
  //     }
  //     return MapEntry(key, value);
  //   });

  //   if (encodableFormDetails['image_path'] != null &&
  //       encodableFormDetails['image_path'].isNotEmpty) {
  //     List<File> images = List<File>.from(encodableFormDetails['image_path']);
  //     encodableFormDetails['image_path'] = images.map((image) {
  //       List<int> imageBytes = image.readAsBytesSync();
  //       return base64Encode(imageBytes);
  //     }).toList();
  //   }

  //   final response = await http.post(
  //     Uri.parse('http://127.0.0.1:8000/api/store'),
  //     headers: {
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(encodableFormDetails),
  //   );

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         duration: Duration(seconds: 1),
  //         content: Text('Form submitted successfully'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } else if (response.statusCode == 422) {
  //     final errors = jsonDecode(response.body)['errors'];
  //     errors.forEach((field, messages) {
  //       _formKey.currentState?.invalidateField(
  //         name: field,
  //         errorText: messages.join(', '),
  //       );
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Validation errors occurred.'),
  //         backgroundColor: Colors.orange,
  //       ),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to submit form'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }
  Future<void> _submitForm(
      Map<String, dynamic> formDetails, BuildContext context) async {
    Dio dio = Dio();

    FormData formData = FormData();

    formDetails.forEach((key, value) async {
      if (value is DateTime) {
        formData.fields.add(MapEntry(key, value.toIso8601String()));
      } else if (value is List<File>) {
        for (var file in value) {
          formData.files.add(MapEntry(
            key,
            await MultipartFile.fromFile(file.path,
                filename: file.path.split('/').last),
          ));
        }
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    try {
      Response response = await dio.post(
        'http://127.0.0.1:8000/api/store',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Form submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 422) {
        final errors = response.data['errors'];
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit form'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on DioError catch (e) {
      // Handle Dio errors, such as network errors
      print('Dio error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit form: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // Future<void> _ssubmitForm(
  //     // BuildContext context,
  //     Map<String, dynamic> formDetails) async {
  //   Map<String, dynamic> encodableFormDetails = formDetails.map((key, value) {
  //     if (value is DateTime) {
  //       return MapEntry(key, value.toIso8601String());
  //     }
  //     return MapEntry(key, value);
  //   });

  //   if (encodableFormDetails['image_path'] != null &&
  //       encodableFormDetails['image_path'].isNotEmpty) {
  //     List<File> images = List<File>.from(encodableFormDetails['image_path']);
  //     encodableFormDetails['image_path'] = images.map((image) {
  //       List<int> imageBytes = image.readAsBytesSync();
  //       return base64Encode(imageBytes);
  //     }).toList();
  //   }

  //   final uri = Uri.parse('http://127.0.0.1:8000/api/store');
  //   final request = http.MultipartRequest('POST', uri)
  //     ..headers.addAll({
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     });

  //   // Add fields to the request
  //   request.fields['encodableFormDetails'] = jsonEncode(encodableFormDetails);

  //   // Add files to the request
  //   if (encodableFormDetails['image_path'] != null) {
  //     List<String> imagePaths =
  //         List<String>.from(encodableFormDetails['image_path']);
  //     for (String path in imagePaths) {
  //       request.files
  //           .add(await http.MultipartFile.fromPath('image_path[]', path));
  //     }
  //   }

  //   final response = await request.send();
  //   final responseBody = await response.stream.bytesToString();

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         duration: Duration(seconds: 1),
  //         content: Text('Form submitted successfully'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } else if (response.statusCode == 422) {
  //     final errors = jsonDecode(responseBody)['errors'];
  //     errors.forEach((field, messages) {
  //       _formKey.currentState?.invalidateField(
  //         name: field,
  //         errorText: messages.join(', '),
  //       );
  //     });

  //     print(
  //         'Validation errors: $errors'); // Add this line to print validation errors

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Validation errors occurred.'),
  //         backgroundColor: Colors.orange,
  //       ),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to submit form'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  Future<void> _updateForm(Map<String, dynamic> formDetails) async {
    Map<String, dynamic> encodableFormDetails = formDetails.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, value.toIso8601String());
      }
      return MapEntry(key, value ?? '');
    });

    final uri =
        Uri.parse('http://127.0.0.1:8000/api/lead_data/${widget.lead!.id}');
    //  Uri.parse('${{ApiEndPoints.baseUrl}widget.lead!.id}');

    final response = await (http.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(encodableFormDetails),
    ));

    if (response.statusCode == 200 || response.statusCode == 201) {
      log('Lead Updated successfully.');
      Fluttertoast.showToast(
        msg: 'Lead Updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNav()),
      );
    } else {
      log('Failed to update: ${response.body}');
      Fluttertoast.showToast(
        msg: 'Failed to update',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lead != null ? 'Edit Lead Details' : 'Add Details'),
      ),
      body: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                FormBuilderImagePicker(
                  name: "image_path",
                  validator: FormBuilderValidators.compose([
                    //  FormBuilderValidators.required(),
                  ]),
                  // initialValue: ,
                  //  key: _formKey,
                  enabled: true,
                  // initialValue: null,
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  autocorrect: true,
                  keyboardType: TextInputType.name,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(3),
                  ]),
                  name: "name",
                  initialValue: widget.lead?.name,
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
                    FormBuilderValidators.numeric(),
                    // (val) {
                    //   if (val == null ||
                    //       !RegExp(r'^(\+91|0)?[789]\d{9}$').hasMatch(val) ||
                    //       !RegExp(r'^[789]\d{9}$').hasMatch(val)) {
                    //     return 'Please enter a valid phone number';
                    //   }
                    //   return null;
                    // },
                  ]),
                  name: "contact_number",
                  initialValue: widget.lead?.contactNumber,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            pickContact();
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
                    initialValue: widget.lead?.whatsapp == 1,
                    validator: FormBuilderValidators.compose([]),
                  ),
                ),
                const SizedBox(height: 15),
                FormBuilderTextField(
                  autocorrect: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.email(),
                  ]),
                  name: "email",
                  initialValue: widget.lead?.email,
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
                  initialValue: widget.lead?.address,
                  decoration: InputDecoration(
                    icon: Icon(Icons.home, color: Colors.blue),
                    label: Text("Address"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                FormBuilderDropdown<String>(
                  name: 'state',
                  // initialValue: widget.lead?.state_id,
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
                      _districts.clear();
                      _cities.clear();
                    });
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 15),
                FormBuilderDropdown<String>(
                  name: 'district',
                  //initialValue: widget.lead?.district_id,
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
                      _cities.clear();
                    });
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 15),
                FormBuilderDropdown<String>(
                  name: 'city',
                  // initialValue: widget.lead?.city_id,
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
                  name: 'location_coordinates',
                  initialValue: widget.lead?.locationCoordinates,
                  decoration: InputDecoration(
                    icon: Icon(Icons.location_on, color: Colors.blue),
                    suffixIcon: IconButton(
                        onPressed: () async {
                          log(currentAddress);
                          print(currentAddress);
                          _getCurrentLocation();
                          try {
                            Position position = await _determinePosition();
                            setState(() {
                              currentPosition = position;
                            });
                            await _getAddressFromLatLng(position);
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg: "Error: $e",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white);
                          }
                        },
                        icon: Icon(Icons.gps_fixed_rounded)),
                    label: Text('Current Location'),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 60),
                  child: Text(_location),
                ),
                const SizedBox(height: 15),
                FormBuilderDropdown<String>(
                  name: 'lead_priority',
                  initialValue: widget.lead?.leadPriority,
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
                FormBuilderRadioGroup<String>(
                  name: 'follow_up',
                  initialValue: widget.lead?.followUp,
                  separator: SizedBox(width: 20),
                  decoration: InputDecoration(
                    icon: Icon(Icons.rate_review, color: Colors.blue),
                    label: Text('Follow Up'),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  options: [
                    FormBuilderFieldOption(value: 'Yes', child: Text('Yes')),
                    FormBuilderFieldOption(value: 'No', child: Text('No')),
                  ],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  onChanged: (value) {
                    _followUpNotifier.value = value == 'Yes';
                  },
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<bool>(
                  valueListenable: _followUpNotifier,
                  builder: (context, followUpEnabled, child) {
                    return FormBuilderDateTimePicker(
                      name: 'follow_up_date',
                      //  initialDate:widget.lead?.follow_up_date,

                      inputType: InputType.date,
                      format: DateFormat('dd-MM-yyyy'),
                      decoration: InputDecoration(
                        labelText: 'Select Date',
                        icon: Icon(Icons.calendar_today, color: Colors.blue),
                        border: OutlineInputBorder(),
                      ),
                      enabled: followUpEnabled,
                      validator: followUpEnabled
                          ? FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                            ])
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _formKey.currentState!.reset();
                            _formKey.currentState!.fields["state"]!
                                .didChange(null);
                            _formKey.currentState!.fields["lead_priority"]!
                                .didChange(null);
                            _formKey.currentState!.fields["follow_up"]!
                                .didChange(null);
                            _formKey.currentState!.fields["follow_up_date"]!
                                .didChange(null);
                          });
                        },
                        child: Text("Clear")),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final formDetails = _formKey.currentState!.value;
                            _submitForm(formDetails, context);

                            log(formDetails.toString());

                            // if (widget.lead != null) {
                            //   _updateForm(formDetails);
                            //   Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => BottomNav(),
                            //       ));
                            // } else {
                            //   _submitForm(formDetails);
                            //   // Navigator.push(
                            //   //     context,
                            //   // MaterialPageRoute(
                            //   //   builder: (context) => BottomNav(),
                            //   // ));
                            // }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to submit form'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            print("falied");
                          }
                        });
                      },
                      child: Text(widget.lead != null ? 'Update' : 'Submit'),
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

  Future<void> pickContact() async {
    PermissionStatus permissionStatus = await Permission.contacts.request();

    if (permissionStatus.isGranted) {
      Contact? contact = await ContactsService.openDeviceContactPicker();
      if (contact != null && contact.phones!.isNotEmpty) {
        setState(() {
          _formKey.currentState?.fields['contact_number']
              ?.didChange(contact.phones!.first.value);
        });
      }
    } else {
      // Handle permission denied scenario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Contacts permission is required to pick a contact')),
      );
    }
  }

  Future<void> _askPermissions(String routeName) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      if (routeName != null) {
        Navigator.of(context).pushNamed(routeName);
      }
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  static Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          currentAddress =
              "${place.subLocality},${place.locality}, ${place.postalCode}, ${place.country}";
        });

        // Update the form field value
        _formKey.currentState?.fields['location_coordinates']
            ?.didChange(currentAddress);
      } else {
        setState(() {
          currentAddress = "No address available";
        });
      }
    } catch (e) {
      setState(() {
        currentAddress = "Error retrieving address";
      });
    }
  }

  Future<void> _fetchStates() async {
    final response =
        //await http.get(Uri.parse('http://127.0.0.1:8000/api/states'));
        await http.get(Uri.parse(
            '${ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.fetchState}'));
    if (response.statusCode == 200) {
      setState(() {
        _states = jsonDecode(response.body);
        _selectedState = widget.lead?.state_id;
      });
    }
  }

  Future<void> _fetchDistricts(String stateId) async {
    final response = await http
        //.get(Uri.parse('http://127.0.0.1:8000/api/districts/$stateId'));
        .get(Uri.parse(
            '${ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.fetchDistrict}$stateId'));
    if (response.statusCode == 200) {
      setState(() {
        _districts = jsonDecode(response.body);
        _selectedDistrict = widget.lead?.district_id;
      });
    }
  }

  Future<void> _fetchCities(String districtId) async {
    final response = await http
        //  .get(Uri.parse('http://127.0.0.1:8000/api/cities/$districtId'));
        .get(Uri.parse(
            '${ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.fetchcity}$districtId'));
    if (response.statusCode == 200) {
      setState(() {
        _cities = jsonDecode(response.body);
        _selectedCity = widget.lead?.city_id;
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
}
