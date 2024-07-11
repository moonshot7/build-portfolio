import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTruckScreen extends StatefulWidget {
  @override
  _AddTruckScreenState createState() => _AddTruckScreenState();
}

class _AddTruckScreenState extends State<AddTruckScreen> {
  final _formKey = GlobalKey<FormState>();
  String truckNum = '';
  String matricule = '';
  String poids = ''; // Changed to String for form handling

  Future<void> addTruck() async {
    final double? poidsValue = double.tryParse(poids);
    if (poidsValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid weight')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://192.168.0.113:3000/trucks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'truck_num': truckNum, 'matricule': matricule, 'poids': poidsValue}),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add truck')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Truck'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Truck Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter truck number';
                  }
                  return null;
                },
                onSaved: (value) {
                  truckNum = value!;
                },
              ),
              TextFormField(
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    addTruck();
                  }
                },
                child: const Text('Add Truck'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
