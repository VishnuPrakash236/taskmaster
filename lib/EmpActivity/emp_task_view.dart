import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../DatabaseHelper/database_helper.dart';
import 'update_task.dart';


class EmpTaskView extends StatefulWidget {
  final String employeeName;

  EmpTaskView({required this.employeeName});

  @override
  State<EmpTaskView> createState() => _EmpTaskView();
}

class _EmpTaskView extends State<EmpTaskView> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _tasksFuture = DatabaseHelper.instance.getTasksForUser(widget.employeeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks for ${widget.employeeName}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> task = snapshot.data![index];
                int? taskId = task[DatabaseHelper.columnTaskId] as int?;
                String priority = task[DatabaseHelper.columnPriority];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: getPriorityColor(priority),
                    child: Text(
                      taskId != null ? taskId.toString() : 'null',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(task[DatabaseHelper.columnTaskName]),
                  subtitle: Text(task[DatabaseHelper.columnTaskType]),
                  trailing: Text(task[DatabaseHelper.columnCompletedPercentage].toString() + "%"),
                  onTap: () => _navigateToUpdateTaskScreen(task),
                );
              },
            );
          }
        },
      ),
    );
  }

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue; // Default color for 'NotSet'
    }
  }

  void _navigateToUpdateTaskScreen(Map<String, dynamic> task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(task: task),
      ),
    );
    _loadTasks(); // Reload tasks after returning from update screen
  }
}
