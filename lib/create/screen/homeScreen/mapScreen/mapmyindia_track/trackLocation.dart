import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lead_application/model/leadModel.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:get/get.dart';
import 'package:lead_application/controller/loginControler.dart';

import '../../../../../db_connection/services/location_services.dart';

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
    _initializeMap();
  }

  void _initializeMap() {
    MapmyIndiaAccountManager.setMapSDKKey('092687bde0df9929d798b1e1ceafc46d');
    MapmyIndiaAccountManager.setRestAPIKey('092687bde0df9929d798b1e1ceafc46d');
    MapmyIndiaAccountManager.setAtlasClientId(
        '96dHZVzsAuvbhuzGkwF-OQJ6j6IWRyqCoaQudy9pQ9Nu8r8EYryJmqqQ-ble0SHjnakEuHnq7iwgmb19ibIuCg==');
    MapmyIndiaAccountManager.setAtlasClientSecret(
        'lrFxI-iSEg_n5Ei3B-_HW9lCAL22Bt9LcQhtflLilZS5b7lLymqZYTHW1FvE_Nonx9iGbJ6Le8aTnn0xhMRHykl73Yl1RExg');
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

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final response = await http.get(Uri.parse(
      'https://apis.mapmyindia.com/advancedmaps/v1/092687bde0df9929d798b1e1ceafc46d/route_adv/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=polyline&overview=full',
    ));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String encodedPolyline = data['routes'][0]['geometry'];
      final List<LatLng> routeCoordinates = decodePolyline(encodedPolyline);

      _addRouteToMap(routeCoordinates);
    } else {
      throw Exception('Failed to fetch route');
    }
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
      lineColor: "#0000FF",
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

  void _addMarker(double lat, double lon, Lead lead) async {
    Symbol symbol = await _mapController.addSymbol(SymbolOptions(
      geometry: LatLng(lat, lon),
      iconImage: 'assets/images/red_location.png',
      iconSize: 0.1,
      textField: lead.name,
      textSize: 20,
      textAnchor: "right",
    ));
  }
}
