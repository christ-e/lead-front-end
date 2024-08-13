import 'package:flutter/material.dart';
import 'package:lead_application/db_connection/services/location_services.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LocationService _locationService = LocationService();
  List<Map<String, dynamic>> _coordinates = [];

  @override
  void initState() {
    super.initState();
    // Set callback to update UI when coordinates are updated
    _locationService.onLocationUpdated = (latitude, longitude) {
      setState(() {
        _fetchCoordinates();
      });
    };
    _locationService.startLogging();
    _fetchCoordinates();
  }

  @override
  void dispose() {
    _locationService.stopLogging();
    super.dispose();
  }

  void _clearData() async {
    await DatabaseHelper.clearCoordinates();
    _fetchCoordinates(); // Refresh the coordinates after clearing
    print('All coordinates cleared');
  }

  Future<void> _fetchCoordinates() async {
    final coordinates = await DatabaseHelper.fetchCoordinates();
    setState(() {
      _coordinates = coordinates;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coordinate Logger'),
        actions: [
          IconButton(
            onPressed: _clearData,
            icon: Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Logging coordinates every 5 seconds'),
            if (_coordinates.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _coordinates.length,
                  itemBuilder: (context, index) {
                    final coordinate = _coordinates[index];
                    return ListTile(
                      title: Text(
                          '${index + 1}. Latitude: ${coordinate['latitude']}, Longitude: ${coordinate['longitude']}'),
                      subtitle: Text('Timestamp: ${coordinate['timestamp']}'),
                    );
                  },
                ),
              )
            else
              Text('No coordinates logged yet'),
          ],
        ),
      ),
    );
  }
}
