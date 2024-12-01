import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:multicast_app/login_page.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String name = _firstnameController.text;

    var response = await http.post(
      Uri.parse('http://192.168.1.95:8000/api/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': username,
        'password': password,
        'name': name
      }),
    );

    if (response.statusCode == 200) {
      // Đăng ký thành công
      final responseData = jsonDecode(response.body);
      log('Register successful: $responseData');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      // Đăng ký thất bại
      log('Register failed: ${response.body}');
      // Hiển thị thông báo lỗi cho người dùng
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('Register page'),
          ),
          TextField(
            controller: _firstnameController,
            decoration: InputDecoration(
              labelText: 'Họ và tên',
            ),
          ),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Tài khoản',
            ),
          ),
          TextField(
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _register();
            },
            child: Text('Đăng ký'),
          ),
        ],
      ),
    );
  }
}
