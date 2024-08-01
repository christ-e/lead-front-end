import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lead_application/services/database_services.dart';

class Offlinescreen extends StatefulWidget {
  const Offlinescreen({super.key});

  @override
  State<Offlinescreen> createState() => _OfflinescreenState();
}

class _OfflinescreenState extends State<Offlinescreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  late Future<List<Map<String, dynamic>>> _leads;

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  void _fetchLeads() {
    setState(() {
      _leads = _databaseService.getAllLeads();
    });
  }

  void _addLead(Map<String, dynamic> lead) async {
    await _databaseService.insertLead(lead);
    _fetchLeads(); // Ensure the leads are fetched again to refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads (Offline)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _leads,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final lead = snapshot.data![index];
                      return ListTile(
                        title: Text(lead['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lead['contact_number'] ?? ""),
                            Text(lead['email'] ?? ""),
                            Text(lead['address'] ?? ""),
                            Text((lead['follow_up_date'] as DateTime?)
                                    ?.toIso8601String() ??
                                ''),
                            Text(lead['state'] ?? ""),
                            Text(lead['district'] ?? ""),
                          ],
                        ),
                      );
                    },
                  ));
                }
                if (snapshot.data!.isEmpty) {
                  return Center(child: Text('No leads found.'));
                }
                return ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final lead = snapshot.data![index];
                    return ListTile(
                      title: Text(lead['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lead['contact_number'] ?? ""),
                          Text(lead['email'] ?? ""),
                          Text(lead['address'] ?? ""),
                          Text(lead['follow_up_date'] ??
                              "********no date*******"),
                          Text(lead['state'] ?? ""),
                          Text(lead['district'] ?? ""),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LeadFormScreen(onSubmit: _addLead)),
                );
              },
              child: Text('Add Lead'),
            ),
          ),
        ],
      ),
    );
  }
}

class LeadFormScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  LeadFormScreen({required this.onSubmit});

  @override
  _LeadFormScreenState createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

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
      // Open file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image, // Restrict to images
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Lead'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // CircleAvatar(
                //   radius: 60,
                //   backgroundImage: _image != null ? FileImage(_image!) : null,
                //   child: _image == null
                //       ? IconButton(
                //           onPressed: () {
                //             showDialog(
                //               context: context,
                //               builder: (BuildContext context) {
                //                 return AlertDialog(
                //                   title: const Text("Add Photo"),
                //                   actions: [
                //                     IconButton(
                //                       onPressed: () {
                //                         _pickImageCamera();
                //                         Navigator.of(context).pop();
                //                       },
                //                       icon: const Column(
                //                         children: [
                //                           Icon(Icons.camera),
                //                           Text("Camera")
                //                         ],
                //                       ),
                //                     ),
                //                     const SizedBox(width: 5),
                //                     IconButton(
                //                       onPressed: () {
                //                         _pickImageGallary();
                //                         Navigator.of(context).pop();
                //                       },
                //                       icon: const Column(
                //                         children: [
                //                           Icon(Icons.image),
                //                           Text("Image")
                //                         ],
                //                       ),
                //                     ),
                //                     const SizedBox(width: 20),
                //                     IconButton(
                //                       onPressed: () async {
                //                         final pickedFile =
                //                             await _picker.pickImage(
                //                                 source: ImageSource.gallery);
                //                         if (pickedFile != null) {
                //                           setState(() {
                //                             _image = File(pickedFile.path);
                //                           });
                //                         } else {
                //                           print('No image selected.');
                //                         }
                //                         Navigator.of(context).pop();
                //                       },
                //                       icon: const Column(
                //                         children: [
                //                           Icon(Icons.folder_copy_rounded),
                //                           Text("Files")
                //                         ],
                //                       ),
                //                     ),
                //                   ],
                //                 );
                //               },
                //             );
                //           },
                //           icon: Icon(Icons.add_a_photo_rounded),
                //           iconSize: 30,
                //         )
                //       : null,
                // ),
                FormBuilderTextField(
                  name: 'name',
                  decoration: InputDecoration(labelText: 'Name'),
                  // validator: FormBuilderValidators.compose([
                  //  // FormBuilderValidators.required(),
                  // ]),
                ),
                FormBuilderTextField(
                  name: 'contact_number',
                  decoration: InputDecoration(labelText: 'Contact Number'),
                  // validator: FormBuilderValidators.compose([
                  //   FormBuilderValidators.required(),
                  //   FormBuilderValidators.numeric(),
                  // ]),
                ),
                FormBuilderTextField(
                  name: 'email',
                  decoration: InputDecoration(labelText: 'Email'),
                  // validator: FormBuilderValidators.compose([
                  //   FormBuilderValidators.required(),
                  //   FormBuilderValidators.email(),
                  // ]),
                ),
                FormBuilderTextField(
                  name: 'address',
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                FormBuilderTextField(
                  name: 'state',
                  decoration: InputDecoration(labelText: 'State'),
                ),
                FormBuilderTextField(
                  name: 'district',
                  decoration: InputDecoration(labelText: 'District'),
                ),
                FormBuilderTextField(
                  name: 'city',
                  decoration: InputDecoration(labelText: 'City'),
                ),
                FormBuilderTextField(
                  name: 'location_coordinates',
                  decoration:
                      InputDecoration(labelText: 'Location Coordinates'),
                ),
                FormBuilderTextField(
                  name: 'location_lat',
                  decoration: InputDecoration(labelText: 'Location Latitude'),
                ),
                FormBuilderTextField(
                  name: 'location_log',
                  decoration: InputDecoration(labelText: 'Location Longitude'),
                ),
                FormBuilderCheckbox(
                  name: 'whats_app',
                  title: Text('WhatsApp'),
                ),
                FormBuilderCheckbox(
                  name: 'follow_up',
                  title: Text('Follow Up'),
                ),
                FormBuilderDateTimePicker(
                  name: 'follow_up_date',
                  inputType: InputType.date,
                  decoration: InputDecoration(labelText: 'Follow Up Date'),
                ),
                FormBuilderTextField(
                  name: 'lead_priority',
                  decoration: InputDecoration(labelText: 'Lead Priority'),
                ),
                FormBuilderTextField(
                  name: 'image_path',
                  decoration: InputDecoration(labelText: 'Image Path'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      var formData = Map<String, dynamic>.from(
                          _formKey.currentState!.value);

                      formData['whats_app'] =
                          formData['whats_app'] == true ? 'true' : 'false';
                      formData['follow_up'] =
                          formData['follow_up'] == true ? 'true' : 'false';

                      // Convert DateTime to String for follow_up_date
                      if (formData['follow_up_date'] != null) {
                        formData['follow_up_date'] =
                            (formData['follow_up_date'] as DateTime)
                                .toIso8601String();
                      }

                      log('Form Data: $formData');
                      widget.onSubmit(formData);
                      Navigator.pop(context);
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
