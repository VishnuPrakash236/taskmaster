import 'dart:io';

import 'package:flutter/material.dart';

import 'add_employee_screen.dart';
import 'edit_employee_screen.dart';
import '../DatabaseHelper/database_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'view_user_screen.dart';

class NewEmployeesScreen extends StatefulWidget {
  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<NewEmployeesScreen> {
  late Future<List<Map<String, dynamic>>> _employeesFuture;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _employeesFuture = _fetchEmployees();
  }

  Future<List<Map<String, dynamic>>> _fetchEmployees() async {
    try {
      DatabaseHelper dbHelper = DatabaseHelper.instance;
      // Fetch only required columns
      List<Map<String, dynamic>> users = await dbHelper.queryAllUsers2();
      selectedImage=null;
      return users;
    } catch (e) {
      print('Error fetching employees: $e');
      return []; // Handle error gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _employeesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No employees found.'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> employee = snapshot.data![index];
                  String employeeName = employee['name'];
                  String avatarText =
                      employeeName.substring(0, 1).toUpperCase();

                  if (employee['imgPath'] != null) {
                    selectedImage = File(employee?['imgPath']);
                  }

                  return Slidable(
                    endActionPane: ActionPane(
                      motion: ScrollMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) =>
                              _editEmployee(context, employee),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                          borderRadius: BorderRadius.circular(64),
                        ),
                      ],
                    ),
                    startActionPane: ActionPane(
                      motion: ScrollMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) =>
                              _deleteEmployee(context, employee),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: selectedImage != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(selectedImage!),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              child: Text(avatarText),
                            ),

                      title: Text(employeeName),
                      onTap: () {
                        _viewUser(context, employee);
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddEmployee(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _editEmployee(BuildContext context, Map<String, dynamic> employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditEmployeeScreen(employee: employee)),
    ).then((_) {
      setState(() {
        _employeesFuture =
            _fetchEmployees(); // Refresh employee list after editing
      });
    });
  }

  void _deleteEmployee(BuildContext context, Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Employee'),
          content: Text(
              'Are you sure you want to delete employee: ${employee['name']}?'),
          actions: [
            TextButton(
              onPressed: () async {
                await _performDeleteEmployee(employee);
                Navigator.pop(context);
                setState(() {
                  _employeesFuture =
                      _fetchEmployees(); // Refresh employee list after deletion
                });
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeleteEmployee(Map<String, dynamic> employee) async {
    try {
      DatabaseHelper dbHelper = DatabaseHelper.instance;
      await dbHelper.deleteUser(employee['_id']);
    } catch (e) {
      print('Error deleting employee: $e');
      // Handle error
    }
  }

  void _navigateToAddEmployee(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEmployeeScreen()),
    ).then((_) {
      setState(() {
        _employeesFuture =
            _fetchEmployees(); // Refresh employee list after adding new employee
      });
    });
  }

  void _viewUser(BuildContext context, Map<String, dynamic> employee) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewUserScreen(user: employee)),
    );
  }
}
