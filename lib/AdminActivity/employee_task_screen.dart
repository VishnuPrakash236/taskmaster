import 'package:flutter/material.dart';
import '../DatabaseHelper/database_helper.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class EmployeeTasksScreen extends StatefulWidget {
  final String employeeName;

  EmployeeTasksScreen({required this.employeeName});

  @override
  State<EmployeeTasksScreen> createState() => _EmployeeTasksScreenState();
}

class _EmployeeTasksScreenState extends State<EmployeeTasksScreen> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _tasksFuture =
          DatabaseHelper.instance.getTasksForUser(widget.employeeName);
    });
  }

  Future<void> _deleteTask(int? taskId) async {
    if (taskId != null) {
      try {
        int rowsAffected = await DatabaseHelper.instance.deleteTask(taskId);
        if (rowsAffected > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task deleted successfully')),
          );
          _loadTasks();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete task')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: $e')),
        );
      }
    }
  }

  Future<void> _deleteAllTasks() async {
    try {
      int rowsAffected = await DatabaseHelper.instance
          .deleteAllTasksForUser(widget.employeeName);
      if (rowsAffected > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All tasks deleted successfully')),
        );
        _loadTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete tasks')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting tasks: $e')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks for ${widget.employeeName}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              bool? taskAdded = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddTaskScreen(employeeName: widget.employeeName),
                ),
              );
              if (taskAdded == true) {
                _loadTasks();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _showDeleteAllTasksDialog,
          ),
        ],
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
                  onTap: () => _showEditTaskScreen(taskId),
                  leading: CircleAvatar(
                    backgroundColor: getPriorityColor(priority),
                    child: Text(
                      taskId != null ? taskId.toString() : 'null',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(task[DatabaseHelper.columnTaskName]),
                  subtitle: Text(task[DatabaseHelper.columnTaskType]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _showDeleteDialog(taskId, task),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showDeleteDialog(int? taskId, Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteTask(taskId);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskScreen(int? taskId) async {
    if (taskId != null) {
      bool? taskUpdated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditTaskScreen(taskId: taskId),
        ),
      );
      if (taskUpdated == true) {
        _loadTasks();
      }
    }
  }

  void _showDeleteAllTasksDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete All Tasks'),
          content: Text(
              'Are you sure you want to delete all tasks for ${widget.employeeName}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete All'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAllTasks();
              },
            ),
          ],
        );
      },
    );
  }
}
