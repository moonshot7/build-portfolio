import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'EditTruckScreen.dart';
import 'AddTruckScreen.dart';

class TrucksManagementScreen extends StatefulWidget {
  @override
  _TrucksManagementScreenState createState() => _TrucksManagementScreenState();
}

class _TrucksManagementScreenState extends State<TrucksManagementScreen> {
  List<dynamic> trucks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrucks();
  }

  Future<void> fetchTrucks() async {
    setState(() {
      isLoading = true;
    });
    final response =
        await http.get(Uri.parse('http://192.168.0.113:3000/trucks'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        trucks = data;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load trucks')),
      );
    }
  }

  Future<void> deleteTruck(String truckNum) async {
    final response = await http
        .delete(Uri.parse('http://192.168.0.113:3000/trucks/$truckNum'));
    if (response.statusCode == 200) {
      setState(() {
        trucks.removeWhere((truck) => truck['truck_num'] == truckNum);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Truck deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete truck')),
      );
    }
  }

  void editTruck(Map<String, dynamic> truck) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTruckScreen(truck: truck),
      ),
    ).then((value) {
      if (value == true) {
        fetchTrucks();
      }
    });
  }

  void addTruck() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTruckScreen(),
      ),
    ).then((value) {
      if (value == true) {
        fetchTrucks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(105, 173, 124, 1),
        title: const Text('Trucks Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addTruck,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: trucks.length,
              itemBuilder: (context, index) {
                final truck = trucks[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.local_shipping,
                        color: const Color.fromRGBO(105, 173, 124, 1)),
                    title: Text(
                        'Truck ${truck['truck_num']} - ${truck['matricule']}'),
                    subtitle: Text('Poids: ${truck['poids']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => editTruck(truck),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteTruck(truck['truck_num']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
