import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:smatrash/screens/driver/history.dart';
import 'package:smatrash/screens/driver/notification.dart';
import 'package:smatrash/screens/driver/report.dart';
import 'package:smatrash/screens/mapscreen.dart';

class HomeD extends StatefulWidget {
  const HomeD({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeD> {
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
    final response = await http.get(Uri.parse('http://100.103.87.181:3000/bins'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        binLocations = data.map((item) => LatLng(item['latitude'], item['longitude'])).toList();
        fillLevels = generateFillLevels(binLocations.length);
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load bin locations')),
      );
    }
  }

  List<int> generateFillLevels(int count) {
    final random = Random();
    return List<int>.generate(count, (index) => 80 + random.nextInt(21));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(217, 217, 217, 100),
                border: Border.all(
                  color: const Color.fromRGBO(105, 173, 124, 100),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.map),
                  SizedBox(width: 10),
                  Text('Map'),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapScreen(
                          binLocations: binLocations,
                          centerLocation: binLocations.isNotEmpty ? binLocations[0] : const LatLng(0, 0))),
                );
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.notifications),
                  SizedBox(width: 10),
                  Text('Notifications'),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.history),
                  SizedBox(width: 10),
                  Text('History'),
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
              title: const Row(
                children: [
                  Icon(Icons.report),
                  SizedBox(width: 10),
                  Text('Report'),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) => Container(
                color: const Color(0xFFD9D9D9),
                child: Stack(
                  children: [
                    const AnimatedTruckImage(),
                    Column(
                      children: [
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              width: 50,
                              height: 50,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Positioned(
                      top: 30,
                      right: 20,
                      child: Row(
                        children: [
                          Text(
                            '12600 | a | 15',
                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.local_shipping),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -180,
                      left: -180,
                      child: Image.asset(
                        'assets/header_bg.png',
                        width: 450,
                        height: 350,
                      ),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.06,
                        child: Transform.scale(
                          scale: 0.98,
                          child: Image.asset(
                            'assets/background.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      left: 10,
                      child: GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: const Opacity(
                          opacity: 0.8,
                          child: Icon(
                            Icons.menu,
                            size: 55,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 170,
                      left: 10,
                      right: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                SizedBox(width: 10),
                                Text(
                                  'Bins',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Stack(
                            children: [
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: binLocations.length,
                                  itemBuilder: (context, index) {
                                    final binLocation = binLocations[index];
                                    final distanceToBin = distance(truckLocation, binLocation).toStringAsFixed(2);
                                    final fillLevel = fillLevels[index];
                                    return buildBinCard(
                                      'Bin ${index + 1}',
                                      'Fill Level: $fillLevel%',
                                      'Distance: $distanceToBin m',
                                      context,
                                      binLocation,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Positioned(
                      top: 440,
                      left: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(40),
                            child: Row(
                              children: [
                                SizedBox(width: 10),
                                Text(
                                  'Truck Fill Level',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 530,
                      left: 100,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: Center(
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Text(
                                '20%',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 35,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 655,
                      left: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Truck Status'),
                                content: const Text('Truck is still empty'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          'Empty',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildBinCard(String name, String fill, String distance, BuildContext context, LatLng binLocation) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.8),
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
            const SizedBox(height: 15),
            Text(
              fill,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
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

class AnimatedTruckImage extends StatefulWidget {
  const AnimatedTruckImage({super.key});

  @override
  _AnimatedTruckImageState createState() => _AnimatedTruckImageState();
}

class _AnimatedTruckImageState extends State<AnimatedTruckImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -89,
      right: -25,
      child: SlideTransition(
        position: _animation,
        child: Image.asset(
          'assets/home_truck.png',
          width: 450,
          height: 350,
        ),
      ),
    );
  }
}
