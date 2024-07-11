import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditBinScreen extends StatefulWidget {
  final Map<String, dynamic> bin;

  EditBinScreen({required this.bin});

  @override
  _EditBinScreenState createState() => _EditBinScreenState();
}

class _EditBinScreenState extends State<EditBinScreen> {
  late TextEditingController serieNumController;
  late TextEditingController nameController;
  late TextEditingController poidsController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    serieNumController =
        TextEditingController(text: widget.bin['serie_num'].toString());
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
      appBar: AppBar(title: const Text('Edit Bin')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: serieNumController,
                    decoration: const InputDecoration(labelText: 'Serie Num'),
                    enabled: false, // Disable editing of the serie_num
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
                    onPressed: updateBin,
                    child: const Text('Update Bin'),
                  ),
                ],
              ),
            ),
    );
  }
}
