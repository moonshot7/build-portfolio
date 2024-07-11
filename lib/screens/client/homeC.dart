import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:smatrash/screens/driver/history.dart';
import 'package:smatrash/screens/driver/notification.dart';
import 'package:smatrash/screens/driver/report.dart';
import 'package:smatrash/screens/mapscreen.dart';

class HomeC extends StatefulWidget {
  const HomeC({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeC> {
  List<LatLng> binLocations = [];
  List<int> fillLevels = [];
  final LatLng truckLocation = const LatLng(34.035404, -4.976526);
  final Distance distance = const Distance();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBinLocations();
  }

  Future<void> fetchBinLocations() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.0.113:3000/bins'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          binLocations = data
              .map((item) => LatLng(item['latitude'], item['longitude']))
              .toList();
          fillLevels = generateFillLevels(binLocations.length);
          isLoading = false;
          sortBinsByProximity();
        });
      } else {
        _showSnackBar('Failed to load bin locations');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void sortBinsByProximity() {
    binLocations.sort((a, b) =>
        distance(truckLocation, a).compareTo(distance(truckLocation, b)));
  }

  List<int> generateFillLevels(int count) {
    final random = Random();
    return List<int>.generate(count, (index) => random.nextInt(101));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9), // Set background color here
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Opacity(
                  opacity: 0.09,
                  child: Image.asset(
                    'assets/client_bg.png',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 25),
                    Center(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            'Closest bins',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: binLocations.length,
                        itemBuilder: (context, index) {
                          final binLocation = binLocations[index];
                          final distanceToBin =
                              distance(truckLocation, binLocation)
                                  .toStringAsFixed(2);
                          final fillLevel = fillLevels[index];
                          if (fillLevel >= 50) {
                            return const SizedBox
                                .shrink(); // Skip bins that are 50% or more
                          }
                          return buildBinCard(
                            'Bin ${index + 1}',
                            'Fill Level: $fillLevel%',
                            'Distance: $distanceToBin m',
                            context,
                            binLocation,
                            fillLevel,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Image.asset(
                        'assets/waste_properly.webp',
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Report',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break; // Current screen
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(
                    binLocations: binLocations,
                    centerLocation: binLocations.isNotEmpty
                        ? binLocations[0]
                        : const LatLng(0, 0),
                  ),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportScreen()),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color.fromRGBO(105, 173, 124, 1),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 5,
        showUnselectedLabels: true,
        selectedLabelStyle:
            const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
      ),
    );
  }

  Widget buildBinCard(String name, String fill, String distance,
      BuildContext context, LatLng binLocation, int fillLevel) {
    return Container(
      width: 140,
      height: 120, // Adjust height here
      margin: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5), // Adjust spacing here
            Text(
              fill,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5), // Adjust spacing here
            Text(
              distance,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        binLocations: binLocations,
                        centerLocation: binLocation,
                        selectedBinLocation: binLocation,
                      ),
                    ),
                  );
                },
                child: const Text('View Route'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
