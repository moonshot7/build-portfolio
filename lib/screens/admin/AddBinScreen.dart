import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddBinScreen extends StatefulWidget {
  @override
  _AddBinScreenState createState() => _AddBinScreenState();
}

class _AddBinScreenState extends State<AddBinScreen> {
  final TextEditingController serieNumController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController poidsController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  bool isLoading = false;

  Future<void> addBin() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.113:3000/bins'),
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
          const SnackBar(content: Text('Bin added successfully')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add bin')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add bin')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    serieNumController.dispose();
    nameController.dispose();
    poidsController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bin')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: serieNumController,
                    decoration: const InputDecoration(labelText: 'Serie Num'),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: poidsController,
                    decoration: const InputDecoration(labelText: 'Poids'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: latitudeController,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: longitudeController,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: addBin,
                    child: const Text('Add Bin'),
                  ),
                ],
              ),
            ),
    );
  }
}
