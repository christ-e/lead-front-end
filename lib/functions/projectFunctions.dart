import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:lead_application/db_connection/services/location_services.dart';
import 'package:permission_handler/permission_handler.dart';

class ProjectFunction extends GetxController {
  Future<void> pickContact(_formKey, context, setState) async {
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
      askPermissions(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Contacts permission is required to pick a contact')),
      );
    }
  }

  Future<void> askPermissions(context) async {
    PermissionStatus permissionStatus = await getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      // if (routeName != null) {
      //   // Navigator.of(context).pushNamed(routeName);
      // }
    } else {
      handleInvalidPermissions(permissionStatus, context);
    }
  }

  Future<PermissionStatus> getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void handleInvalidPermissions(PermissionStatus permissionStatus, context) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      SnackBar(
        content: Text('Please enable Your Location Service'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.blueGrey,
        behavior: SnackBarBehavior
            .floating, // Optional: change this to normal if you don't want floating behavior
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), // Optional: add a border radius for a more rounded effect
      );
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        SnackBar(
          content: Text('Location permissions are denied'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior
              .floating, // Optional: change this to normal if you don't want floating behavior
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ), // Optional: add a border radius for a more rounded effect
        );
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      SnackBar(
        content: Text(
            'Location permissions are permanently denied, we cannot request permissions.'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.blueGrey,
        behavior: SnackBarBehavior
            .floating, // Optional: change this to normal if you don't want floating behavior
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), // Optional: add a border radius for a more rounded effect
      );
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> getAddressFromLatLng(
      Position position, setState, currentAddress, _formKey) async {
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

  Future<void> getCurrentLocation(
      setState, _location, _lat, _log, _formKey) async {
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

  Future<void> NetworkSubmit(_formKey, _submitForm_Offline, _showAlertDialog,
      _updateForm, _submitForm, _location, context, widget) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final formKey = _formKey.currentState!.value;
      var formData = Map<String, dynamic>.from(_formKey.currentState!.value);

      log('Form Data: $formData');

      // Check network connection
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {
        // No internet connection, submit offline
        _submitForm_Offline(formData);
        print("Request successful");
        _showAlertDialog(context, 'Success', 'Form submitted Offline');
      } else {
        // Internet connection available, submit onliane
        if (widget.lead != null) {
          _updateForm(formKey);
        } else {
          log(formKey.toString());
          _submitForm(formKey, _location);
        }
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
  }

  //map Functions
  Future<void> _fetchCoordinates(setState, _coordinates) async {
    final coordinates = await DatabaseHelper.fetchCoordinates();
    setState(() {
      _coordinates = coordinates;
    });
  }
}
