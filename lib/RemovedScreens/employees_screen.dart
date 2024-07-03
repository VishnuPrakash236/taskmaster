import 'package:flutter/material.dart';
import '../AdminActivity/add_employee_screen.dart';
import '../AdminActivity/view_user_screen.dart';
import '../DatabaseHelper/database_helper.dart';
import '../AdminActivity/edit_employee_screen.dart'; // Import the ViewUserScreen class

class EmployeesScreen extends StatefulWidget {
  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late Future<List<Map<String, dynamic>>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _employeesFuture = _fetchEmployees();
  }

  Future<List<Map<String, dynamic>>> _fetchEmployees() async {
    try {
      DatabaseHelper dbHelper = DatabaseHelper.instance;
      List<Map<String, dynamic>> users = await dbHelper.queryAllUsers();
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
                String avatarText = employeeName.substring(0, 1).toUpperCase();

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(avatarText),
                  ),
                  title: Text(employeeName),
                  onTap: () {
                    _viewUser(context, employee);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editEmployee(context, employee);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteEmployee(context, employee);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
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
      MaterialPageRoute(builder: (context) => EditEmployeeScreen(employee: employee)),
    ).then((_) {
      setState(() {
        _employeesFuture = _fetchEmployees(); // Refresh employee list after editing
      });
    });
  }

  void _deleteEmployee(BuildContext context, Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Employee'),
          content: Text('Are you sure you want to delete employee: ${employee['name']}?'),
          actions: [
            TextButton(
              onPressed: () async {
                await _performDeleteEmployee(employee);
                Navigator.pop(context);
                setState(() {
                  _employeesFuture = _fetchEmployees(); // Refresh employee list after deletion
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
        _employeesFuture = _fetchEmployees(); // Refresh employee list after adding new employee
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
