import 'package:flutter/material.dart';

import '../DatabaseHelper/database_helper.dart';
import 'employee_task_screen.dart';


class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    try {
      DatabaseHelper dbHelper = DatabaseHelper.instance;
      return await dbHelper.queryAllUsers();
    } catch (e) {
      print('Error fetching users: $e');
      return []; // Handle error gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> user = snapshot.data![index];
                String name = user['name'];
                String email = user['email'];

                return ListTile(
                  title: Text(name),
                  subtitle: Text(email),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployeeTasksScreen(employeeName: name),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
