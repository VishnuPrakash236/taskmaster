import 'package:flutter/material.dart';

import '../DatabaseHelper/database_helper.dart';
import 'DashboardCont.dart';

class NewEmpTaskView extends StatefulWidget {
  final String employeeName;

  const NewEmpTaskView({super.key, required this.employeeName});

  @override
  State<NewEmpTaskView> createState() => _NewEmpTaskViewState();
}

class _NewEmpTaskViewState extends State<NewEmpTaskView> {
  late Future<List<Map<String, dynamic>>> tasksFuture;

  @override
  void initState() {
    super.initState();
    tasksFuture = DatabaseHelper.instance.getTasksForUser(widget
        .employeeName); // Replace 'employeeName' with the actual employee name
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        title: Text('Task For ${widget.employeeName}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: tasksFuture,
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
                String priority = task[DatabaseHelper.columnPriority];
                String taskType = task[DatabaseHelper.columnTaskType];
                String taskName = task[DatabaseHelper.columnTaskName];
                String taskDate = task[DatabaseHelper.columnDueDate].toString();
                String taskComp =
                    task[DatabaseHelper.columnCompletedPercentage].toString();

                return DashboardCont(
                  priority: priority,
                  taskType: taskType,
                  taskTitle: taskName,
                  taskdate: taskDate,
                  taskComp: taskComp,
                  taskMap: task,
                );
              },
            );
          }
        },
      ),
    );
  }
}