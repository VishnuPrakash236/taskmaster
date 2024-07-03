import 'package:flutter/material.dart';

import '../DatabaseHelper/database_helper.dart';


class UpdateTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  UpdateTaskScreen({required this.task});

  @override
  _UpdateTaskScreenState createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _status;
  double _completedPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _status = widget.task[DatabaseHelper.columnStatus];
    _completedPercentage = widget.task[DatabaseHelper.columnCompletedPercentage]?.toDouble() ?? 0.0;
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      Map<String, dynamic> updatedTask = {
        DatabaseHelper.columnTaskId: widget.task[DatabaseHelper.columnTaskId],
        DatabaseHelper.columnTaskName: widget.task[DatabaseHelper.columnTaskName],
        DatabaseHelper.columnTaskType: widget.task[DatabaseHelper.columnTaskType],
        DatabaseHelper.columnPriority: widget.task[DatabaseHelper.columnPriority],
        DatabaseHelper.columnDueDate: widget.task[DatabaseHelper.columnDueDate],
        DatabaseHelper.columnEmployeeName: widget.task[DatabaseHelper.columnEmployeeName],
        DatabaseHelper.columnStatus: _status,
        DatabaseHelper.columnCompletedPercentage: _completedPercentage.round(),
      };
      await DatabaseHelper.instance.updateTask(updatedTask);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(labelText: 'Status'),
                items: ['Not Started', 'In Progress', 'Completed']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text('Completed Percentage: ${_completedPercentage.round()}%'),
              Slider(
                value: _completedPercentage,
                min: 0,
                max: 100,
                divisions: 100,
                label: _completedPercentage.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _completedPercentage = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateTask,
                child: Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
