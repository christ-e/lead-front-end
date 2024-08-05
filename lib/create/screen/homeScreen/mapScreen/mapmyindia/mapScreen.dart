import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lead_application/model/leadModel.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapmyIndiaMapController _mapController;
  List<Lead> leads = [];
  late Symbol _currentLocationMarker;
  late LatLng _currentLatLng;
  Lead lead = Lead();
  Map<Symbol, Lead> _markerLeadMap = {}; // Map to associate markers with leads
  Lead? _selectedLead; // To store the currently selected lead

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

    _fetchLeads();
    _checkLocationPermission();
  }

  Future<void> _fetchLeads() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/api/lead'));

    if (response.statusCode == 200) {
      final List<dynamic> leadJson = json.decode(response.body);
      setState(() {
        leads = leadJson.map((json) => Lead.fromJson(json)).toList();
      });

      for (var lead in leads) {
        if (lead.location_lat != null && lead.location_log != null) {
          _addMarker(lead.location_lat!, lead.location_log!, lead);
        }
      }
    } else {
      throw Exception('Failed to load leads');
    }
  }

  Future<void> _checkLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      _getCurrentLocation();
    } else {
      // Handle permission denial here if necessary
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });

    _mapController.moveCamera(
      CameraUpdate.newLatLng(
        _currentLatLng,
      ),
    );

    _currentLocationMarker = await _mapController.addSymbol(SymbolOptions(
      geometry: _currentLatLng,
      // iconImage: 'assets/images/location_pin_icon.png',
      iconSize: 0.3,
    ));

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _mapController.moveCamera(
          CameraUpdate.newLatLng(
            _currentLatLng,
          ),
        );
        _mapController.updateSymbol(
          _currentLocationMarker,
          SymbolOptions(
            geometry: _currentLatLng,
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads Location'),
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
              onPressed: () {
                _showOptions();
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.more_vert),
            ),
            SizedBox(
              height: 20,
            ),
            FloatingActionButton(
              onPressed: () {
                _fetchRoute(
                  LatLng(10.0101232, 76.3132234),
                  // LatLng(_currentLocationMarker.options.geometry!.latitude,
                  //     _currentLocationMarker.options.geometry!.longitude),
                  // LatLng(double.parse(lead.location_lat!),
                  //     double.parse(lead.location_log!)),
                  LatLng(10.01021333,
                      76.3134345), // Replace with the destination coordinates
                );
                // _fetchRoute(
                //   _currentLatLng,
                //   LatLng(
                //     double.parse(_selectedLead!.location_lat ?? '0'),
                //     double.parse(_selectedLead!.location_log ?? '0'),
                //   ),
                // );
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.directions),
            ),
            SizedBox(
              height: 20,
            ),
            FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.lightBlue.shade100,
                child: Icon(Icons.gps_fixed_outlined)),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final response = await http.get(Uri.parse(
      'https://apis.mapmyindia.com/advancedmaps/v1/092687bde0df9929d798b1e1ceafc46d/route_adv/driving/${76.31767},${10.01091212};${76.31632365},${10.01011112}?geometries=polyline&overview=full',
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
      lineColor: "#ff0000",
      lineWidth: 5.0,
      lineOpacity: 0.8,
    ));
  }

  void _addMarker(double lat, double lon, Lead lead) async {
    Symbol symbol = await _mapController.addSymbol(
        SymbolOptions(
            geometry: LatLng(lat, lon),
            iconImage: 'assets/images/red_location.png',
            iconSize: 0.6,
            textField: lead.name,
            textSize: 20,
            textAnchor: "right"),
        _markerLeadMap);
    _showDetails(lead);
    // Associate the marker with its lead
    _markerLeadMap[symbol] = lead;
  }

  void _showDetails(Lead lead) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lead Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${lead.name}'),
              Text('Contact: ${lead.contactNumber}'),
              Text('Address: ${lead.address}'),
              Text('Location: ${lead.locationCoordinates}'),
              Text('Coordinates: ${lead.location_lat}, ${lead.location_log}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 30,
            right: 100,
            left: 100,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Handle "Warm" option here
                },
                child: Text('Warm'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Handle "Hot" option here
                },
                child: Text('Hot'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Handle "Cold" option here
                },
                child: Text('Cold'),
              ),
            ],
          ),
        );
      },
    );
  }
}
