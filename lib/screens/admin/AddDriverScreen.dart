import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddDriverScreen extends StatefulWidget {
  @override
  _AddDriverScreenState createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  String truckNum = '';
  String role = '';

  Future<void> addDriver() async {
    final response = await http.post(
      Uri.parse('http://192.168.0.113:3000/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'truck_num': truckNum,
        'role': role
      }),
    );
    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add driver')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Driver'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
                onSaved: (value) {
                  username = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value!;
                },
              ),
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
                decoration: const InputDecoration(labelText: 'Role'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter role';
                  }
                  return null;
                },
                onSaved: (value) {
                  role = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    addDriver();
                  }
                },
                child: const Text('Add Driver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
