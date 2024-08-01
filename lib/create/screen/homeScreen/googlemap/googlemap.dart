import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:lead_application/model/leadModel.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController _mapController;
  List<Lead> leads = [];
  late Marker _currentLocationMarker;
  late LatLng _currentLatLng;
  Lead? _selectedLead; // To store the currently selected lead

  Map<MarkerId, Lead> _markerLeadMap =
      {}; // Map to associate markers with leads
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
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
          _addMarker(
            double.parse(lead.location_lat!),
            double.parse(lead.location_log!),
            lead,
          );
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
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLng(_currentLatLng),
    );

    setState(() {
      _currentLocationMarker = Marker(
        markerId: MarkerId('currentLocation'),
        position: _currentLatLng,
        icon: BitmapDescriptor.defaultMarker,
      );
      _markers.add(_currentLocationMarker);
    });

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
        _mapController.animateCamera(
          CameraUpdate.newLatLng(_currentLatLng),
        );

        _markers.removeWhere(
            (marker) => marker.markerId.value == 'currentLocation');
        _currentLocationMarker = Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentLatLng,
          icon: BitmapDescriptor.defaultMarker,
        );
        _markers.add(_currentLocationMarker);
      });
    });
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${10.01011112},${76.31632365}&destination=${10.01091212},${76.31767}&key=AIzaSyAiJiOJZivORC1G7EBzmui4xZWEiyoea6A',
    ));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String encodedPolyline =
          data['routes'][0]['overview_polyline']['points'];
      final List<LatLng> routeCoordinates = _decodePolyline(encodedPolyline);

      _addRouteToMap(routeCoordinates);
    } else {
      throw Exception('Failed to fetch route');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
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
    final polyline = Polyline(
      polylineId: PolylineId('route'),
      points: routeCoordinates,
      color: Colors.red,
      width: 5,
    );

    setState(() {
      _polylines.add(polyline);
    });
  }

  void _addMarker(double lat, double lon, Lead lead) {
    final marker = Marker(
      markerId: MarkerId(lead.id.toString()),
      position: LatLng(lat, lon),
      infoWindow: InfoWindow(
        title: lead.name,
        snippet: lead.address,
        onTap: () => _onMarkerTapped(lead),
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(lead.leadPriority == "Warm"
          ? BitmapDescriptor.hueOrange
          : lead.leadPriority == "Hot"
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueBlue),
    );

    setState(() {
      _markers.add(marker);
      _markerLeadMap[marker.markerId] = lead;
    });
  }

  void _onMarkerTapped(Lead lead) {
    setState(() {
      _selectedLead = lead;
    });

    _showDetails(lead);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads Location'),
      ),
      body: GoogleMap(
        // mapType: MapType.satellite,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(10.0109851, 76.3132312),
          zoom: 13,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _markers,
        polylines: _polylines,
      ),
      floatingActionButton: Column(
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
              if (_selectedLead != null) {
                _fetchRoute(
                  _currentLatLng, // Current location
                  LatLng(10.0109851, 76.3132312
                      // double.parse(_selectedLead!.location_lat ?? '0'),
                      // double.parse(_selectedLead!.location_log ?? '0'),
                      ), // Destination from selected lead
                );
              }
            },
            backgroundColor: Colors.lightBlue.shade100,
            child: Icon(Icons.directions),
          ),
          // SizedBox(
          //   height: 20,
          // ),
          // FloatingActionButton(
          //   onPressed: () {},
          //   backgroundColor: Colors.lightBlue.shade100,
          //   child: Icon(Icons.gps_fixed_outlined),
          // ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}
