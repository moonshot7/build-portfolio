import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smatrash/screens/driver/history.dart';
import 'package:smatrash/screens/driver/notification.dart';
import 'package:smatrash/screens/driver/report.dart';
import 'mapbox_directions_service.dart';

class MapScreen extends StatefulWidget {
  final List<LatLng> binLocations;
  final LatLng centerLocation;
  final LatLng? selectedBinLocation;

  const MapScreen({
    super.key,
    required this.binLocations,
    required this.centerLocation,
    this.selectedBinLocation,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapboxDirectionsService _directionsService;
  List<LatLng> _routePoints = [];
  LatLng? _truckLocation;

  @override
  void initState() {
    super.initState();
    _directionsService = MapboxDirectionsService(
        'pk.eyJ1IjoibW9vbnNob290IiwiYSI6ImNsd2R4eGQ4MjFiaXcycXBsdTZneGVleTIifQ.qmZ_jXPQ0jUGs7AeozDZqg');
    _fetchTruckLocation();
    if (widget.selectedBinLocation != null) {
      _fetchRoute(widget.selectedBinLocation!);
    }
  }

  Future<void> _fetchTruckLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, don't continue
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _truckLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _fetchRoute(LatLng binLocation) async {
    await _fetchTruckLocation(); // Ensure the truck location is updated in real-time
    if (_truckLocation != null) {
      final route = await _directionsService.getRoute(
        _truckLocation!,
        binLocation,
      );
      setState(() {
        _routePoints = route;
      });
    }
  }

  void _showBinInfoDialog(LatLng binLocation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bin Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Location: (${binLocation.latitude}, ${binLocation.longitude})'),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _fetchRoute(binLocation);
                    },
                    child: const Text('Show Route'),
                  ),
                ],
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
        backgroundColor: const Color(0xFF68AC7B),
        title: Row(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/splashlogo.png',
                width: 50,
                height: 50,
              ),
            ),
            const Spacer(),
            const Row(
              children: [
                Text(
                  '12600 | a | 15',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Icon(Icons.local_shipping),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(217, 217, 217, 1),
                border: Border.all(
                  color: const Color.fromRGBO(105, 173, 124, 1),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20, // Reduced font size
                  ),
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 5.0, horizontal: 16.0), // Reduced padding
              title: const Row(
                children: [
                  Icon(Icons.map, size: 20), // Reduced icon size
                  SizedBox(width: 10),
                  Text('Map',
                      style: TextStyle(fontSize: 16)), // Reduced font size
                ],
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 5.0, horizontal: 16.0), // Reduced padding
              title: const Row(
                children: [
                  Icon(Icons.notifications, size: 20), // Reduced icon size
                  SizedBox(width: 10),
                  Text('Notifications',
                      style: TextStyle(fontSize: 16)), // Reduced font size
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 5.0, horizontal: 16.0), // Reduced padding
              title: const Row(
                children: [
                  Icon(Icons.history, size: 20), // Reduced icon size
                  SizedBox(width: 10),
                  Text('History',
                      style: TextStyle(fontSize: 16)), // Reduced font size
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 5.0, horizontal: 16.0), // Reduced padding
              title: const Row(
                children: [
                  Icon(Icons.report, size: 20), // Reduced icon size
                  SizedBox(width: 10),
                  Text('Report',
                      style: TextStyle(fontSize: 16)), // Reduced font size
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Content(),
    );
  }

  Widget Content() {
    return FlutterMap(
      options: MapOptions(
        center: widget.centerLocation,
        zoom: 15,
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.doubleTapZoom,
      ),
      children: [
        openStreetMapTileLayer,
        MarkerLayer(
          markers: [
            if (_truckLocation != null)
              Marker(
                point: _truckLocation!,
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.local_shipping,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ...widget.binLocations.map((bin) => Marker(
                  point: bin,
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      _showBinInfoDialog(bin);
                    },
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                )),
          ],
        ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
      ],
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
