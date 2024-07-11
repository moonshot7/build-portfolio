import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'AddBinScreen.dart';
import 'EditBinScreen.dart';
import 'TrucksManagementScreen.dart';
import 'DriversManagementScreen.dart';

class HomeA extends StatefulWidget {
  const HomeA({super.key});

  @override
  _HomeAState createState() => _HomeAState();
}

class _HomeAState extends State<HomeA> {
  List<dynamic> bins = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBins();
  }

  Future<void> fetchBins() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.113:3000/bins'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        bins = data;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load bins')),
      );
    }
  }

  Future<void> deleteBin(int binId) async {
    final response =
        await http.delete(Uri.parse('http://192.168.0.113:3000/bins/$binId'));
    if (response.statusCode == 200) {
      setState(() {
        bins.removeWhere((bin) => bin['serie_num'] == binId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bin deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete bin')),
      );
    }
  }

  void editBin(Map<String, dynamic> bin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBinScreen(bin: bin),
      ),
    ).then((value) {
      if (value == true) {
        fetchBins();
      }
    });
  }

  void addBin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBinScreen(),
      ),
    ).then((value) {
      if (value == true) {
        fetchBins();
      }
    });
  }

  void navigateToTrucksManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrucksManagementScreen(),
      ),
    );
  }

  void navigateToDriversManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriversManagementScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(105, 173, 124, 1),
        title: const Text('Management Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/splashlogo.png',
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.delete,
                  color: Color.fromRGBO(105, 173, 124, 1)),
              title: const Text('Bins Management'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BinsManagementScreen(
                      bins: bins,
                      isLoading: isLoading,
                      fetchBins: fetchBins,
                      deleteBin: deleteBin,
                      editBin: editBin,
                      addBin: addBin,
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.local_shipping,
                  color: Color.fromRGBO(105, 173, 124, 1)),
              title: const Text('Trucks Management'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: navigateToTrucksManagement,
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.person,
                  color: Color.fromRGBO(105, 173, 124, 1)),
              title: const Text('Drivers Management'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: navigateToDriversManagement,
            ),
          ),
        ],
      ),
    );
  }
}

// Bins Management Screen
class BinsManagementScreen extends StatelessWidget {
  final List<dynamic> bins;
  final bool isLoading;
  final Function fetchBins;
  final Function deleteBin;
  final Function editBin;
  final Function addBin;

  BinsManagementScreen({
    required this.bins,
    required this.isLoading,
    required this.fetchBins,
    required this.deleteBin,
    required this.editBin,
    required this.addBin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(105, 173, 124, 1),
        title: const Text('Bins Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => addBin(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bins.length,
              itemBuilder: (context, index) {
                final bin = bins[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.white,
                  child: ListTile(
                    title: Text('Bin ${bin['serie_num']} - ${bin['name']}'),
                    subtitle: Text('Poids: ${bin['poids']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => editBin(bin),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteBin(bin['serie_num']),
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
