import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditDriverScreen extends StatefulWidget {
  final Map<String, dynamic> driver;

  EditDriverScreen({required this.driver});

  @override
  _EditDriverScreenState createState() => _EditDriverScreenState();
}

class _EditDriverScreenState extends State<EditDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  late int id;
  late String username;
  late String password;
  late String truckNum;
  late String role;

  @override
  void initState() {
    super.initState();
    id = widget.driver['id'];
    username = widget.driver['username'] ?? ''; // Ensure non-null string
    password = widget.driver['password'] ?? ''; // Ensure non-null string
    truckNum =
        widget.driver['truck_num']?.toString() ?? ''; // Ensure non-null string
    role = widget.driver['role'] ?? ''; // Ensure non-null string
  }

  Future<void> editDriver() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final response = await http.put(
        Uri.parse('http://192.168.0.113:3000/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'truck_num': truckNum,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to edit driver')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Driver'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: username,
                decoration: const InputDecoration(labelText: 'Username'),
                readOnly: true,
              ),
              TextFormField(
                initialValue: password,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value ?? '';
                },
              ),
              TextFormField(
                initialValue: truckNum,
                decoration: const InputDecoration(labelText: 'Truck Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a truck number';
                  }
                  return null;
                },
                onSaved: (value) {
                  truckNum = value ?? '';
                },
              ),
              TextFormField(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a role';
                  }
                  return null;
                },
                onSaved: (value) {
                  role = value ?? '';
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    editDriver();
                  }
                },
                child: const Text('Edit Driver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
