import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../DatabaseHelper/database_helper.dart';


class AddTaskScreen extends StatefulWidget {
  final String employeeName;

  AddTaskScreen({Key? key, required this.employeeName}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskTypeController = TextEditingController();
  String _selectedPriority = 'NotSet';
  DateTime? _selectedDate;

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() async {
    if (_taskNameController.text.isNotEmpty &&
        _taskTypeController.text.isNotEmpty &&
        _selectedPriority.isNotEmpty &&
        _selectedDate != null) {
      try {
        String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

        Map<String, dynamic> taskData = {
          'employee_name': widget.employeeName,
          'task_name': _taskNameController.text,
          'task_type': _taskTypeController.text,
          'priority': _selectedPriority,
          'due_date': formattedDate,
        };

        // Insert task into the database using TaskDatabaseHelper
        int taskId = await DatabaseHelper.instance.insertTask(taskData);

        if (taskId != -1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task saved successfully')),
          );
          Navigator.pop(context, true); // Pass true to indicate a task was added
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save task')),
          );
        }
      } catch (e) {
        print('Error saving task: $e');
        // Handle error as needed
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill all fields and select a due date.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _taskTypeController,
              decoration: InputDecoration(labelText: 'Task Type'),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: InputDecoration(labelText: 'Priority'),
              items: <String>['High', 'Medium', 'Low', 'NotSet'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPriority = newValue!;
                });
              },
            ),
            SizedBox(height: 16.0),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Select Due Date'
                    : 'Due Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
              ),
              trailing: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: _pickDate,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveTask,
        child: Icon(Icons.save),
      ),
    );
  }
}
