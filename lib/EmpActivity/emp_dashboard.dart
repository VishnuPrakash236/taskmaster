import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;


import '../AdminActivity/new_emp_task_view.dart';
import '../DatabaseHelper/database_helper.dart';
import 'emp_task_view.dart';
import 'select_task_for_remarks.dart';


class EmployeeDashboard extends StatefulWidget {
  final String employeeName;

  EmployeeDashboard({required this.employeeName});

  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;
  late Future<List<int>> overall;
  late Future<int> total;
  late int sum;
  late int avg;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    calcOverall();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _tasksFuture =
          DatabaseHelper.instance.getTasksForUser(widget.employeeName);
    });
    calcOverall();
  }

  Future<void> calcOverall() async {
    // Set the state to update the UI
    setState(() {
      overall = DatabaseHelper.instance
          .getUserCompletePercentage(widget.employeeName)
          .then((value) =>
              value ??
              [
                0
              ]); // Assuming getUserCompletePercentage returns a Future<List<int>>
    });

    // Calculate the total sum once `overall` completes
    total = overall.then((value) {
      // Calculate the sum of the list values
      sum = value.reduce((a, b) => a + b);
      return sum;
    }).catchError((error) {
      // Handle errors if any
      print("Error: $error");
      return 0; // Return 0 in case of an error
    });
    overall.then((value) {
      avg = (sum ~/ value.length); // Get the length of the list
      print("Length of overall:");
      print(avg);
    }).catchError((error) {
      print("Error getting overall length: $error");
    });

    Map<String, dynamic> insertPercentage = {
      'name': widget.employeeName,
      'OverAllPercentage': avg
    };
    print((insertPercentage));

    DatabaseHelper.instance.insertOverAll(insertPercentage);
  }

  List<charts.Series<TaskCompletion, String>> _createSampleData(
      List<Map<String, dynamic>> tasks) {
    final data = tasks.map((task) {
      return TaskCompletion(
        taskId: task[DatabaseHelper.columnTaskId].toString(),
        completionPercentage:
            task[DatabaseHelper.columnCompletedPercentage] ?? 0,
        priority: task[DatabaseHelper.columnPriority] ?? 'NotSet',
        taskName: task[DatabaseHelper.columnTaskName] ?? 'Unnamed Task',
      );
    }).toList();

    return [
      charts.Series<TaskCompletion, String>(
        id: 'TaskCompletion',
        colorFn: (TaskCompletion task, _) {
          switch (task.priority.toLowerCase()) {
            case 'high':
              return charts.MaterialPalette.red.shadeDefault;
            case 'medium':
              return charts.MaterialPalette.yellow.shadeDefault;
            case 'low':
              return charts.MaterialPalette.green.shadeDefault;
            default:
              return charts.MaterialPalette.blue.shadeDefault;
          }
        },
        domainFn: (TaskCompletion task, _) => task.taskId,
        measureFn: (TaskCompletion task, _) => task.completionPercentage,
        data: data,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Dashboard'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildCard(
                  context,
                  'View Tasks',
                  Icons.assignment,
                  Colors.green,
                  () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            // EmpTaskView(employeeName: widget.employeeName),
                            NewEmpTaskView(employeeName: widget.employeeName,),
                      ),
                    );
                    _loadTasks(); // Refresh chart data when coming back
                  },
                ),
                _buildCard(
                  context,
                  'Remarks',
                  Icons.note_add_outlined,
                  Colors.blue,
                  () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectTaskForRemarks(
                            employeeName: widget.employeeName),
                      ),
                    );
                    _loadTasks(); // Refresh chart data when coming back
                  },
                ),
              ],
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
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
                  onLongPressStart: (details) {
                    _showTaskNameDialog(
                        context, details.localPosition, snapshot.data!);
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: SizedBox(
                      height: 200.0,
                      child: charts.BarChart(
                        _createSampleData(snapshot.data!),
                        animate: true,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showTaskNameDialog(
      BuildContext context, Offset position, List<Map<String, dynamic>> tasks) {
    final taskCompletion = _getTaskCompletionAtPosition(position, tasks);
    if (taskCompletion != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Task Name'),
          content: Text(taskCompletion.taskName),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  TaskCompletion? _getTaskCompletionAtPosition(
      Offset position, List<Map<String, dynamic>> tasks) {
    final RenderBox barChartBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = barChartBox.globalToLocal(position);
    final double chartWidth = barChartBox.size.width;
    final double barWidth =
        chartWidth / tasks.length.toDouble(); // Calculate each bar width

    final int barIndex = (localPosition.dx / barWidth).floor();

    if (barIndex >= 0 && barIndex < tasks.length) {
      final task = tasks[barIndex];
      return TaskCompletion(
        taskId: task[DatabaseHelper.columnTaskId].toString(),
        completionPercentage:
            task[DatabaseHelper.columnCompletedPercentage] ?? 0,
        priority: task[DatabaseHelper.columnPriority] ?? 'NotSet',
        taskName: task[DatabaseHelper.columnTaskName] ?? 'Unnamed Task',
      );
    }

    return null;
  }

  Widget _buildCard(BuildContext context, String title, IconData icon,
      Color color, Function() onTap) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 50.0, color: color),
              SizedBox(height: 10.0),
              Text(title, style: TextStyle(fontSize: 18.0)),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskCompletion {
  final String taskId;
  final int completionPercentage;
  final String priority;
  final String taskName;

  TaskCompletion(
      {required this.taskId,
      required this.completionPercentage,
      required this.priority,
      required this.taskName});
}
