import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:multicast_app/list_user.dart';
import 'package:multicast_app/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    var response = await http.post(
      Uri.parse('http://192.168.1.95:8000/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Đăng nhập thành công
      final responseData = jsonDecode(response.body);
      log('Login successful: $responseData');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ListUserPage(
                accessToken: responseData['access_token'].toString())),
      );
    } else {
      // Đăng nhập thất bại
      log('Login failed: ${response.body}');
      // Hiển thị thông báo lỗi cho người dùng
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Column(
        children: [
          Center(
            child: Text('Login page'),
          ),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
            ),
          ),
          TextField(
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              labelText: 'passs',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _login,
            child: Text('Login'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterPage()),
              );
            },
            child: Text('Register'),
          ),
        ],
      ),
    );
  }
}
