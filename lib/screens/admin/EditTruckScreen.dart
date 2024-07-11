import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditTruckScreen extends StatefulWidget {
  final Map<String, dynamic> truck;

  EditTruckScreen({required this.truck});

  @override
  _EditTruckScreenState createState() => _EditTruckScreenState();
}

class _EditTruckScreenState extends State<EditTruckScreen> {
  final _formKey = GlobalKey<FormState>();
  late String truckNum;
  late String matricule;
  late String poids;

  @override
  void initState() {
    super.initState();
    truckNum = widget.truck['truck_num']
        .toString(); // Ensure it's a string for initial form value
    matricule = widget.truck['matricule'];
    poids = widget.truck['poids']
        .toString(); // Ensure it's a string for initial form value
  }

  Future<void> editTruck() async {
    final double? poidsValue = double.tryParse(poids);
    if (poidsValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid weight')),
      );
      return;
    }

    final response = await http.put(
      Uri.parse('http://192.168.0.113:3000/trucks/$truckNum'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'matricule': matricule, 'poids': poidsValue}),
    );
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to edit truck')),
      );
    }
  }

  Future<void> deleteTruck() async {
    final response = await http.delete(
      Uri.parse('http://192.168.0.113:3000/trucks/$truckNum'),
    );
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete truck')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Truck'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: truckNum,
                decoration: const InputDecoration(labelText: 'Truck Number'),
                readOnly: true,
              ),
              TextFormField(
                initialValue: matricule,
                decoration: const InputDecoration(labelText: 'Matricule'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter matricule';
                  }
                  return null;
                },
                onSaved: (value) {
                  matricule = value!;
                },
              ),
              TextFormField(
                initialValue: poids,
                decoration: const InputDecoration(labelText: 'Poids'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter valid poids';
                  }
                  return null;
                },
                onSaved: (value) {
                  poids = value!;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        editTruck();
                      }
                    },
                    child: const Text('Edit Truck'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      deleteTruck();
                    },
                    child: const Text('Delete Truck'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
