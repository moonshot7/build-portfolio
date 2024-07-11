import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BinDetailScreen extends StatefulWidget {
  final Map<String, dynamic> bin;

  BinDetailScreen({required this.bin});

  @override
  _BinDetailScreenState createState() => _BinDetailScreenState();
}

class _BinDetailScreenState extends State<BinDetailScreen> {
  late TextEditingController serieNumController;
  late TextEditingController nameController;
  late TextEditingController poidsController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    serieNumController = TextEditingController(text: widget.bin['serie_num']);
    nameController = TextEditingController(text: widget.bin['name']);
    poidsController =
        TextEditingController(text: widget.bin['poids'].toString());
    latitudeController =
        TextEditingController(text: widget.bin['latitude'].toString());
    longitudeController =
        TextEditingController(text: widget.bin['longitude'].toString());
  }

  Future<void> updateBin() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse('http://192.168.0.113:3000/bins/${widget.bin['serie_num']}'),
        body: jsonEncode({
          'serie_num': serieNumController.text,
          'name': nameController.text,
          'poids': double.parse(poidsController.text),
          'latitude': double.parse(latitudeController.text),
          'longitude': double.parse(longitudeController.text),
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bin updated successfully')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update bin')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update bin')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(105, 173, 124, 1),
        title: const Text('Bin Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
                'assets/splashlogo.png'), // Add your logo asset here
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: serieNumController,
              label: 'Serie Number',
              icon: Icons.delete,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: nameController,
              label: 'Name',
              icon: Icons.delete,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: poidsController,
              label: 'Poids',
              icon: Icons.delete,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: latitudeController,
              label: 'Latitude',
              icon: Icons.delete,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: longitudeController,
              label: 'Longitude',
              icon: Icons.delete,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: isLoading ? null : updateBin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(105, 173, 124, 1),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Update Bin'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromRGBO(105, 173, 124, 1)),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
