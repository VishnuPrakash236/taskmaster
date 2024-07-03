import 'package:flutter/material.dart';

class ViewUserScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  ViewUserScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Name: ${user['name']}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Email: ${user['email']}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Role: ${user['role']}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
