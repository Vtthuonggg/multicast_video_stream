import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class ListUserPage extends StatefulWidget {
  String accessToken;
  ListUserPage({super.key, required this.accessToken});

  @override
  State<ListUserPage> createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage> {
  List<dynamic> users = [];
  bool loading = false;
  @override
  void initState() {
    log(widget.accessToken.toString());
    fetchUser();
    super.initState();
  }

  Future<void> fetchUser() async {
    setState(() {
      loading = true;
    });
    var response = await http.get(
      Uri.parse('http://192.168.1.95:8000/api/user-list'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      // Đăng nhập thành công
      log(response.toString());
      users = jsonDecode(response.body);
      setState(() {
        loading = false;
      });
    } else {
      log('Login failed: ${response.body}');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const CircularProgressIndicator(
              color: Colors.blue,
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(users[index]['name']),
                  subtitle: Text(users[index]['email']),
                );
              },
            ),
    );
  }
}
