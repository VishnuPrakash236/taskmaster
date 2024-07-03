import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../DatabaseHelper/database_helper.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  // late Future<List<Map<String, dynamic>>> task;
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>>? task;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    loadAlltask();
  }

  Future<void> loadAlltask() async {
    task = await dbHelper.getAllTasks();
    print(task);
    print(task?.length.toString());
    for (int i = 0; i < task!.length; i++) {
      Map<String, dynamic> taskSaperate = task![i];
      // print(task![i]);
      print(taskSaperate);
    }
  }

  Future<void> _loadTasks() async {
    setState(() {
      _tasksFuture = DatabaseHelper.instance.getAllTasks();
    });
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
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No tasks available'));
                } else {
                  return GestureDetector(
                    onLongPressStart: (details) {},
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height:  600,
                        child: charts.BarChart(
                          _createSampleData(snapshot.data!),
                          animate: true,
                          vertical:false,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          // ElevatedButton(onPressed: (){
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => EmployeesScreen()),
          // );}, child: Text('press'))
        ],
      ),
    );
  }

  List<charts.Series<TaskCompletion, String>> _createSampleData(
      List<Map<String, dynamic>> tasks) {
    final data = tasks.map((task) {
      return TaskCompletion(
        taskId: task[DatabaseHelper.columnTaskId].toString(),
        completionPercentage:
            task[DatabaseHelper.columnCompletedPercentage] ?? 0,
        // priority: task[DatabaseHelper.columnPriority] ?? 'NotSet',
        // taskName: task[DatabaseHelper.columnTaskName] ?? 'Unnamed Task',
      );
    }).toList();

    return [
      charts.Series<TaskCompletion, String>(
        id: 'TaskCompletion',
        domainFn: (TaskCompletion task, _) => task.taskId,
        measureFn: (TaskCompletion task, _) => task.completionPercentage,
        data: data,
      ),
    ];
  }
}

class TaskCompletion {
  final String taskId;
  final int completionPercentage;

  TaskCompletion({required this.taskId, required this.completionPercentage});
}