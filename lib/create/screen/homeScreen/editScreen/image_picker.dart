import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class FormBuilderImagePicker extends FormBuilderField<File> {
  final ImagePicker _picker = ImagePicker();

  FormBuilderImagePicker({
    Key? key,
    required String name,
    FormFieldValidator<File>? validator,
    File? initialValue,
    bool enabled = true,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
  }) : super(
          key: key,
          name: name,
          validator: validator,
          initialValue: initialValue,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<File> field) {
            final state = field as _FormBuilderImagePickerState;

            return Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  state.value != null
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(state.value!),
                        )
                      : CircleAvatar(
                          radius: 70,
                          child: Icon(Icons.person),
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: () async {
                        await showDialog(
                          context: state.context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Pick an Image'),
                              actions: [
                                IconButton(
                                  onPressed: () async {
                                    final pickedFile = await ImagePicker()
                                        .pickImage(source: ImageSource.camera);
                                    if (pickedFile != null) {
                                      state.didChange(File(pickedFile.path));
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.camera_alt),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final pickedFile = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);
                                    if (pickedFile != null) {
                                      state.didChange(File(pickedFile.path));
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.filter),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.add_a_photo_outlined,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

  @override
  FormBuilderFieldState<FormBuilderImagePicker, File> createState() =>
      _FormBuilderImagePickerState();
}

class _FormBuilderImagePickerState
    extends FormBuilderFieldState<FormBuilderImagePicker, File> {
  @override
  void didChange(File? value) {
    super.didChange(value);
  }
}
