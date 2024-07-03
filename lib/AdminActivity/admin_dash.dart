import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

import '../DatabaseHelper/database_helper.dart';
import '../login_page.dart';
import 'new_employees_screen.dart';
import 'new_status_screen.dart';
import 'print_screen.dart';
import 'task_list_screen.dart';
import 'view_all_remaks.dart';

class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    _countRemark();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Perform logout action here
              _logout(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            _buildCard(
              context,
              'Employees',
              Icons.people,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewEmployeesScreen()),
                );
              },
            ),
            _buildCard(
              context,
              'Tasks',
              Icons.assignment,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskListScreen()),
                );
              },
            ),
            //nothing
            _buildCard(
              context,
              'Status',
              Icons.leaderboard,
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  // MaterialPageRoute(builder: (context) => StatusScreen()),
                  MaterialPageRoute(
                      builder: (context) => OverallPercentageChartScreen()),
                );
              },
            ),
            _buildCardWithBadge(
              context,
              'Remarks',
              Icons.note_add_outlined,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewRemaks()),
                );
                initState();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PrintReportScreen()),
          );
          initState();
        },
        child: Icon(Icons.print),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon,
      Color color, Function() onTap) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: InkWell(
        splashColor: color,
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 50.0, color: color),
              SizedBox(height: 10.0),
              Text(
                title,
                style: TextStyle(fontSize: 18.0),
                softWrap: true,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardWithBadge(BuildContext context, String title, IconData icon,
      Color color, Function() onTap) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FutureBuilder<int?>(
                future: _countRemark(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return badges.Badge(
                      badgeContent: Text("..."), // Placeholder while loading
                      child: Icon(
                        icon,
                        size: 50.0,
                        color: color,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return badges.Badge(
                      badgeContent: Text("Error"), // Display error if any
                      child: Icon(
                        icon,
                        size: 50.0,
                        color: color,
                      ),
                    );
                  } else {
                    int count = snapshot.data ?? 0; // Get count or default to 0
                    return badges.Badge(
                      badgeContent: Text(count.toString()), // Display the count
                      child: Icon(
                        icon,
                        size: 50.0,
                        color: color,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 10.0),
              Text(
                title,
                style: TextStyle(fontSize: 18.0),
                softWrap: true,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> _countRemark() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>>? user = await dbHelper.queryResultStatus();
    print(user);
    if (user != null) {
      return user.length; // Return the count of entries in the map
    } else {
      return null; // Return null if no user data was found
    }
  }

  void _logout(BuildContext context) {
    // Perform any logout logic here, such as clearing user session, navigating to login screen, etc.
    // For example, you might want to navigate back to the login screen:// Replace '/login' with your actual login screen route
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
