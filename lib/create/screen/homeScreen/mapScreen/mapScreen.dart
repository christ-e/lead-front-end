import 'package:flutter/material.dart';
import 'package:lead_application/model/leadModel.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapmyIndiaMapController _mapController;
  List<Lead> leads = [
    // Add your list of leads here
    Lead(location_lat: 10.0109851, location_log: 76.3132312),
    Lead(location_lat: 10.0123456, location_log: 76.3145678),
    //Add more leads as needed
  ];

  @override
  void initState() {
    super.initState();

    MapmyIndiaAccountManager.setMapSDKKey('092687bde0df9929d798b1e1ceafc46d');
    MapmyIndiaAccountManager.setRestAPIKey('092687bde0df9929d798b1e1ceafc46d');
    MapmyIndiaAccountManager.setAtlasClientId(
        '96dHZVzsAuvbhuzGkwF-OQJ6j6IWRyqCoaQudy9pQ9Nu8r8EYryJmqqQ-ble0SHjnakEuHnq7iwgmb19ibIuCg==');
    MapmyIndiaAccountManager.setAtlasClientSecret(
        "lrFxI-iSEg_n5Ei3B-_HW9lCAL22Bt9LcQhtflLilZS5b7lLymqZYTHW1FvE_Nonx9iGbJ6Le8aTnn0xhMRHykl73Yl1RExg");
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

          for (var lead in leads) {
            _addMarker(lead.location_lat!, lead.location_log!);
          }
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
                AlertDialog(
                  content: Text("Current location"),
                );
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.gps_fixed_sharp),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _addMarker(double lat, double lon) {
    // void initState() {
    //   super.initState();
    _mapController.addSymbol(SymbolOptions(
        geometry: LatLng(lat, lon),
        iconImage: 'assets/images/location_pin_icon.png',
        iconSize: 0.1));
    //   }
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
