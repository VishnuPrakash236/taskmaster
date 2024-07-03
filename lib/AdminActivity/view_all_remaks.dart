import 'package:flutter/material.dart';

import '../DatabaseHelper/database_helper.dart';
import 'view_selected_remarks.dart';

class ViewRemaks extends StatefulWidget {
  const ViewRemaks({super.key});

  @override
  State<ViewRemaks> createState() => _ViewRemaksState();
}

class _ViewRemaksState extends State<ViewRemaks> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _tasksFuture = DatabaseHelper.instance.getRemarksForAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Remark'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No remarks available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> task = snapshot.data![index];
                int? taskId = task[DatabaseHelper.columnTaskId] as int?;
                String priority = task[DatabaseHelper.columnPriority];
                print(task);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      taskId != null ? taskId.toString() : 'null',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(task[DatabaseHelper.columnEmployeeName]),
                  subtitle: Text(
                      task[DatabaseHelper.columnRemarksSubject] != null
                          ? task[DatabaseHelper.columnRemarksSubject]
                          : 'null'),
                  // trailing: Text(task[DatabaseHelper.columnCompletedPercentage].toString() + "%"),
                  onTap: () => _navToViewSelectedRemarks(
                      task[DatabaseHelper.columnTaskId],
                      task[DatabaseHelper.columnTaskName]),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _navToViewSelectedRemarks(int taskId, String taskName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ViewSelectedRemarks(taskId: taskId, taskName: taskName),
      ),
    );
    _loadTasks(); // Reload tasks after returning from update screen
  }
}
