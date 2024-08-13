// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_print, use_build_context_synchronously, unused_element

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lead_application/constant/api_Endpoints.dart';
import 'package:lead_application/controller/loginControler.dart';
import 'package:lead_application/create/screen/homeScreen/widget/bottom_nav.dart';
import 'package:lead_application/model/leadModel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:lead_application/model/user_model.dart';
import 'package:lead_application/db_connection/services/database_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddDetailsScreen extends StatefulWidget {
  final Lead? lead; //add

  const AddDetailsScreen({super.key, this.lead}); //add

  @override
  State<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String _location = '';
  String _lat = '';
  String _log = '';
  bool isButtonSelected = false;

  List<dynamic> _states = [];
  List<dynamic> _districts = [];
  List<dynamic> _cities = [];

  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedCity;

  String currentAddress = 'My Location';
  Position? currentPosition;

  final List<String> _priorities = ['Hot', 'Warm', 'Cold'];
  late Usermodels users;

  final ValueNotifier<bool> _followUpNotifier = ValueNotifier(false);

  final DatabaseService _databaseService = DatabaseService.instance;
  late Future<List<Map<String, dynamic>>> _leads;

  LoginController loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    // fetchUsers();
    _fetchLeads();

    _fetchStates();
    if (widget.lead != null) {
      _initializeLeadData(widget.lead!);
    }
  }

  void _fetchLeads() {
    setState(() {
      _leads = _databaseService.getAllLeads();
    });
  }

  void _submitForm_Offline(Map<String, dynamic> lead) async {
    final userid = await SharedPreferences.getInstance();
    (lead['follow_up_date'] as DateTime?)?.toIso8601String() ?? '';

    lead['user_id'] = userid.getInt('userId');
    lead['name'] = lead['name'] ?? "";
    lead['contact_number'] = lead['contact_number'] ?? "";
    lead['email'] = lead['email'] ?? "";
    lead['address'] = lead['address'] ?? "";
    lead['state'] = lead['state'];
    lead['district'] = lead['district'];
    lead['city'] = lead['city'];
    lead['location_coordinates'] = lead['location_coordinates'] ?? "";
    lead['location_lat'] = _lat;
    lead['location_log'] = _log;
    lead['image_path'] = _image?.path;
    lead['follow_up'] = lead['follow_up'];
    lead['lead_priority'] = lead['lead_priority'] ?? "";
    lead['whats_app'] = lead['whats_app'] == true ? '0' : '1';
    lead['follow_up'] = lead['follow_up'] == true ? 'Yes' : 'No';
    await _databaseService.insertLead(lead);
    _fetchLeads();
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
        'location_lat': lead.location_lat ?? '',
        'location_log': lead.location_log ?? '',
        'lead_priority': lead.leadPriority ?? '',
        'follow_up': lead.followUp ?? false,
        'follow_up_date': lead.follow_up_date != null
            ? DateTime.parse(lead.follow_up_date!)
            : null,
      });
      _selectedState = lead.state_id;
      _selectedDistrict = lead.district_id;
      _selectedCity = lead.city_id;

      if (_selectedState != null) {
        _fetchDistricts(_selectedState!);
      }
      if (_selectedDistrict != null) {
        _fetchCities(_selectedDistrict!);
      }
    });
  }

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageGallary() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _pickImageCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }

    Future<void> _pickImageFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        // Get the file
        PlatformFile file = result.files.first;
        setState(() {
          _image = File(file.path!);
        });
      }
    }
  }

  Future<void> _submitForm(
    Map<String, dynamic> formKey,
    String? location,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/api/store'),
    );
    final userid = await SharedPreferences.getInstance();
    // await pref.getString('userId');

    ;

    request.headers['Content-Type'] = 'application/json';
    request.headers['Authorization'] = 'Bearer ${loginController.logtoken}';

    request.fields['name'] = formKey['name'] ?? "";
    request.fields['user_id'] = userid.getInt('userId').toString();
    request.fields['contact_number'] = formKey['contact_number'] ?? "";
    request.fields['whats_app'] = formKey['whats_app'] ? '1' : '0';
    request.fields['email'] = formKey['email'] ?? "";
    request.fields['address'] = formKey['address'] ?? "";
    request.fields['state'] = formKey['state'] ?? "";
    request.fields['district'] = formKey['district'] ?? "";
    request.fields['city'] = formKey['city'] ?? "";
    request.fields['location_coordinates'] =
        formKey['location_coordinates'] ?? "";
    request.fields['location_lat'] = _lat;
    request.fields['location_log'] = _log;
    request.fields['follow_up'] = formKey['follow_up'] ?? "";
    request.fields['follow_up_date'] =
        (formKey['follow_up_date'] as DateTime?)?.toIso8601String() ?? "";
    request.fields['lead_priority'] = formKey['lead_priority'] ?? "";

    if (_image != null) {
      var file = await http.MultipartFile.fromPath('image_path', _image!.path);
      request.files.add(file);
    }

    var response = await request.send();

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Request successful");
      _showAlertDialog(context, 'Success', 'Form submitted successfully');
    } else {
      print("Request failed with status: ${response.statusCode}");
      var responseBody = await response.stream.bytesToString();
      print("Response body: $responseBody");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Form submission failed')));
      _showAlertDialog(context, 'Error', 'Form submission failed');
    }
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BottomNav(),
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateForm(Map<String, dynamic> formKey) async {
    Map<String, dynamic> encodableFormDetails = formKey.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, value.toIso8601String());
      }
      return MapEntry(key, value ?? '');
    });

    final uri =
        Uri.parse('http://127.0.0.1:8000/api/lead_data/${widget.lead!.id}');

    final response = await (http.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${loginController.logtoken}',
      },
      body: jsonEncode(encodableFormDetails),
    ));

    if (response.statusCode == 200 || response.statusCode == 201) {
      log('Lead Updated successfully.');
      Fluttertoast.showToast(
        msg: 'Lead Updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_LEFT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pop(
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
    var submitTextStyle = TextStyle(
        fontSize: 18,
        letterSpacing: 2,
        color: Colors.black,
        fontWeight: FontWeight.w300);
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
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Add Photo"),
                                      actions: [
                                        IconButton(
                                          onPressed: () {
                                            _pickImageCamera();
                                            Navigator.of(context).pop();
                                          },
                                          icon: const Column(
                                            children: [
                                              Icon(Icons.camera),
                                              Text("Camera")
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        IconButton(
                                          onPressed: () {
                                            _pickImageGallary();
                                            Navigator.of(context).pop();
                                          },
                                          icon: const Column(
                                            children: [
                                              Icon(Icons.image),
                                              Text("Image")
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        IconButton(
                                          onPressed: () async {
                                            final pickedFile =
                                                await _picker.pickImage(
                                                    source:
                                                        ImageSource.gallery);

                                            if (pickedFile != null) {
                                              setState(() {
                                                _image = File(pickedFile.path);
                                              });
                                            } else {
                                              print('No image selected.');
                                            }
                                            Navigator.of(context).pop();
                                          },
                                          icon: const Column(
                                            children: [
                                              Icon(Icons.folder_copy_rounded),
                                              Text("Files")
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.add_a_photo_rounded),
                              iconSize: 30,
                            )
                          : null,
                    ),
                    if (_image != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        top: 100,
                        left: 100,
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Edit Photo"),
                                  actions: [
                                    IconButton(
                                      onPressed: () {
                                        _pickImageCamera();
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Column(
                                        children: [
                                          Icon(Icons.camera),
                                          Text("Camera")
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    IconButton(
                                      onPressed: () {
                                        _pickImageGallary();
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Column(
                                        children: [
                                          Icon(Icons.image),
                                          Text("Image")
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    IconButton(
                                      onPressed: () async {
                                        final pickedFile =
                                            await _picker.pickImage(
                                                source: ImageSource.gallery);

                                        if (pickedFile != null) {
                                          setState(() {
                                            _image = File(pickedFile.path);
                                          });
                                        } else {
                                          print('No image selected.');
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Column(
                                        children: [
                                          Icon(Icons.folder_copy_rounded),
                                          Text("Files")
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.black,
                          ),
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 15,
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
                    // FormBuilderValidators.max(12),
                    // FormBuilderValidators.min(10),
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
                  // readOnly: true,
                  name: 'location_coordinates',
                  //  initialValue: widget.lead?.locationCoordinates,
                  initialValue: widget.lead?.locationCoordinates,
                  decoration: InputDecoration(
                    icon: Icon(Icons.location_on, color: Colors.blue),
                    suffixIcon: IconButton(
                        onPressed: () async {
                          log(_location);
                          //log(currentPosition.toString());
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
                  child: Text(_location.toString()),
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
                    AnimatedButton(
                      onPress: () {
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
                      width: 120,
                      height: 50,
                      text: 'CLEAR',
                      isReverse: true,
                      selectedTextColor: Colors.lightBlue.shade200,
                      transitionType: TransitionType.TOP_CENTER_ROUNDER,
                      textStyle: submitTextStyle,
                      backgroundColor: Colors.blue.shade200,
                      borderColor: Colors.white,
                      borderWidth: 1,
                      borderRadius: 10,
                      animatedOn: AnimatedOn.onTap,
                    ),
                    AnimatedButton(
                      onPress: () {
                        setState(() async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final formKey = _formKey.currentState!.value;
                            var formData = Map<String, dynamic>.from(
                                _formKey.currentState!.value);

                            log('Form Data: $formData');
                            _submitForm_Offline(formData);
                            if (widget.lead != null) {
                              _updateForm(formKey);
                            } else {
                              log(formKey.toString());
                              _submitForm(formKey, _location);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to submit form'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            print("Failed");
                          }
                        });
                      },
                      width: 120, // Adjusted width
                      height: 50,
                      text: widget.lead != null ? 'UPDATE' : 'SUBMIT',
                      isReverse: true,
                      selectedTextColor: Colors.black,
                      transitionType: TransitionType.TOP_CENTER_ROUNDER,
                      textStyle: submitTextStyle,
                      backgroundColor: Colors.blue.shade200,
                      borderColor: Colors.white,
                      borderWidth: 1,
                      borderRadius: 10,
                      animatedOn: AnimatedOn.onHover,
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
    final response = await http.get(Uri.parse(
      '${ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.fetchState}',
    ));
    if (response.statusCode == 200) {
      setState(() {
        _states = jsonDecode(response.body);
        _selectedState = widget.lead?.state_id;
      });
    }
  }

  Future<void> _fetchDistricts(String stateId) async {
    final response = await http.get(Uri.parse(
        '${ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.fetchDistrict}$stateId'));
    if (response.statusCode == 200) {
      setState(() {
        _districts = jsonDecode(response.body);
        _selectedDistrict = widget.lead?.district_id;
      });
    }
  }

  Future<void> _fetchCities(String districtId) async {
    final response = await http.get(Uri.parse(
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

      _lat = position.latitude.toString();
      _log = position.longitude.toString();
    });
    _formKey.currentState?.fields['location_coordinates'];
  }
}
