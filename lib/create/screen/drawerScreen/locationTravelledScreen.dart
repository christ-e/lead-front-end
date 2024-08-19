import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:get/get.dart';
import 'package:lead_application/controller/loginControler.dart';

import '../../../db_connection/services/location_services.dart';

class LocationTrack extends StatefulWidget {
  const LocationTrack({super.key});

  @override
  State<LocationTrack> createState() => _LocationTrackState();
}

class _LocationTrackState extends State<LocationTrack> {
  late MapmyIndiaMapController _mapController;

  LoginController loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    _fetchAndPlotCoordinates();
    _initializeMap();
  }

  void _initializeMap() {
    MapmyIndiaAccountManager.setMapSDKKey('a8a3dd13fefde11e7d659443db7774a6');
    MapmyIndiaAccountManager.setRestAPIKey('a8a3dd13fefde11e7d659443db7774a6');
    MapmyIndiaAccountManager.setAtlasClientId(
        '96dHZVzsAut3fFLedvk3GCAmKZcYO8Zz_Z5wHV9RGJNdYSzvfSRSAveAJRSWdePKDedJm0cuB4v3S77yw4luFQzi_lR3URyM');
    MapmyIndiaAccountManager.setAtlasClientSecret(
        'lrFxI-iSEg8zm13Fcz_LT5PDzmcuY9TNEmotLh0bi5MZ8bREn0rJmYhO2pJnPKownUNDY8CdNJgjQAWB6ZVXfDjrjreNFHIL0ka_nD7A7WQ=');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Travelled'),
      ),
      body: MapmyIndiaMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(10.0109851, 76.3132312),
          zoom: 13,
        ),
        onMapCreated: (mapController) {
          _mapController = mapController;
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () async {
                await _fetchAndPlotCoordinates();
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.directions),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return poly;
  }

  void _addRouteToMap(List<LatLng> routeCoordinates) {
    _mapController.addLine(LineOptions(
      geometry: routeCoordinates,
      lineColor: "#FA2214",
      lineWidth: 5.0,
      lineOpacity: 0.8,
    ));
  }

  Future<void> _fetchAndPlotCoordinates() async {
    try {
      final List<Map<String, dynamic>> result =
          await DatabaseHelper.fetchCoordinates();

      if (result.isNotEmpty) {
        final List<LatLng> coordinates = result.map((coord) {
          return LatLng(coord['latitude'], coord['longitude']);
        }).toList();

        _addRouteToMap(coordinates);
      } else {
        print('No coordinates found in the database');
      }
    } catch (e) {
      print('Error fetching coordinates: $e');
    }
  }
}