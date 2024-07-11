import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smatrash/screens/admin/homeA.dart';
import 'package:smatrash/screens/client/homeC.dart';
import 'package:smatrash/screens/driver/homeD.dart';
import 'package:http/http.dart' as http;

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loginFailed = false;

  Future<void> login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    final response = await http.post(
      Uri.parse('http://192.168.0.113:3000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String role = data['role'];

      Widget homeScreen;
      switch (role) {
        case 'admin':
          homeScreen = const HomeA();
          break;
        case 'driver':
          homeScreen = const HomeD();
          break;
        default:
          homeScreen = const HomeC(); // Default to client if role is unknown
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homeScreen),
      );
    } else if (response.statusCode == 400) {
      // Unauthorized
      setState(() {
        _loginFailed = true;
      });
    } else {
      // Handle other errors, such as server errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 217, 217, 217),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Image(
                    image: AssetImage('assets/logo.png'),
                    width: 150,
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 15),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            final username =
                                RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value);
                            if (!username) {
                              return 'Please enter a valid username';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            hintText: 'Enter your username',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CheckboxListTile(
                    value: _rememberMe,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _rememberMe = value;
                      });
                    },
                    title: const Text('Remember me'),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF68AC7B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          login();
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_loginFailed)
                    const Text(
                      'Username or password is incorrect',
                      style: TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      print('Navigating to HomeC...');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeC()),
                      );
                    },
                    child: const Text(
                      'Continue as Client',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
