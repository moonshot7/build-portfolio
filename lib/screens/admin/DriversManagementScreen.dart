import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AddDriverScreen.dart';
import 'EditDriverScreen.dart';

class DriversManagementScreen extends StatefulWidget {
  @override
  _DriversManagementScreenState createState() =>
      _DriversManagementScreenState();
}

class _DriversManagementScreenState extends State<DriversManagementScreen> {
  List<dynamic> drivers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.113:3000/users'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        drivers = data;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load drivers')),
      );
    }
  }

  Future<void> deleteDriver(int id) async {
    final response =
        await http.delete(Uri.parse('http://192.168.0.113:3000/users/$id'));
    if (response.statusCode == 200) {
      setState(() {
        drivers.removeWhere((driver) => driver['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete driver')),
      );
    }
  }

  void editDriver(Map<String, dynamic> driver) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDriverScreen(driver: driver),
      ),
    ).then((value) {
      if (value == true) {
        fetchDrivers();
      }
    });
  }

  void addDriver() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDriverScreen(),
      ),
    ).then((value) {
      if (value == true) {
        fetchDrivers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(105, 173, 124, 1),
        title: const Text('Drivers Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addDriver,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.person,
                        color: const Color.fromRGBO(105, 173, 124, 1)),
                    title: Text('Driver: ${driver['username']}'),
                    subtitle: Text('Truck Number: ${driver['truck_num']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => editDriver(driver),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteDriver(driver['id']),
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
