import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../DatabaseHelper/database_helper.dart';

class EditTaskScreen extends StatefulWidget {
  final int taskId;

  EditTaskScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _taskNameController;
  late TextEditingController _taskTypeController;
  late TextEditingController _priorityController;
  late DateTime? _selectedDate;
  String _selectedPriority = 'NotSet';

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController();
    _taskTypeController = TextEditingController();
    _priorityController = TextEditingController();
    _selectedDate = null;
    _loadTaskDetails();
  }

  Future<void> _loadTaskDetails() async {
    try {
      Map<String, dynamic> task =
          await DatabaseHelper.instance.getTaskById(widget.taskId);

      setState(() {
        _taskNameController = TextEditingController(text: task['task_name']);
        _taskTypeController = TextEditingController(text: task['task_type']);
        _priorityController = TextEditingController(text: task['priority']);
        _selectedDate = DateTime.parse(task['due_date']);
      });
    } catch (e) {
      print('Error loading task details: $e');
      // Handle error as needed
    }
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateTask() async {
    if (_taskNameController.text.isNotEmpty &&
        _taskTypeController.text.isNotEmpty &&
        _priorityController.text.isNotEmpty &&
        _selectedDate != null) {
      try {
        String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

        Map<String, dynamic> updatedTaskData = {
          '_taskID': widget.taskId,
          'task_name': _taskNameController.text,
          'task_type': _taskTypeController.text,
          'priority': _selectedPriority,
          'due_date': formattedDate,
        };

        int rowsAffected =
            await DatabaseHelper.instance.updateTask(updatedTaskData);

        if (rowsAffected > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task updated successfully')),
          );
          Navigator.pop(
              context, true); // Pass true to indicate a task was updated
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update task')),
          );
        }
      } catch (e) {
        print('Error updating task: $e');
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
        title: Text('Edit Task'),
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
              items: <String>['High', 'Medium', 'Low', 'NotSet']
                  .map((String value) {
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
        onPressed: _updateTask,
        child: Icon(Icons.save),
      ),
    );
  }
}
