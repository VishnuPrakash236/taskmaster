import 'package:flutter/material.dart';
import '../DatabaseHelper/database_helper.dart';
import 'edit_task_screen.dart';

class ViewSelectedRemarks extends StatefulWidget {
  final int taskId;
  final String taskName;

  const ViewSelectedRemarks(
      {super.key, required this.taskId, required this.taskName});

  @override
  State<ViewSelectedRemarks> createState() => _ViewSelectedRemarksState();
}

class _ViewSelectedRemarksState extends State<ViewSelectedRemarks> {
  late TextEditingController _remarksController;
  late TextEditingController _subjectController;
  String ExistingRemarks = "";
  late Map<String, dynamic> task;
  int _maxLines = 1;

  @override
  void initState() {
    super.initState();
    loadTaskDetails();
    _remarksController = TextEditingController();
    _remarksController.addListener(_updateMaxLines);
    _subjectController = TextEditingController();
  }

  void _updateMaxLines() {
    final int lineCount = '\n'.allMatches(_remarksController.text).length + 1;
    setState(() {
      _maxLines = lineCount;
    });
  }

  Future<void> loadTaskDetails() async {
    try {
      task = await DatabaseHelper.instance.getTaskById(widget.taskId);

      ExistingRemarks = task['remarks'];
    } catch (e) {
      print('Error loading task details: $e');
      // Handle error as needed
    }
    setState(() {
      _remarksController = TextEditingController(text: task['remarks']);
      _subjectController =
          TextEditingController(text: task['remarks_subject'].toString());
    });

    print("1" + ExistingRemarks);
  }

  @override
  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remarks for ${widget.taskName}'),
        actions: <Widget>[

          IconButton(
            icon: Icon(Icons.check),
            onPressed: _markAsRead,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  controller: _remarksController,
                  decoration: InputDecoration(
                    labelText: 'Remarks',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditTaskScreen(taskId: widget.taskId,)),);
                      },
                      child: Text('Edit'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateRemarks,
        // onPressed: () {},
        child: Icon(Icons.save),
      ),
    );
  }

  Future<void> _updateRemarks() async {
    print(_subjectController.text);
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      Map<String, dynamic> updatedRemarks = {
        DatabaseHelper.columnTaskId: widget.taskId,
        DatabaseHelper.columnRemarks: _remarksController.text,
        DatabaseHelper.columnRemarksSubject: _subjectController.text,
        DatabaseHelper.columnRemarksStat: "not_opened",
      };
      int rowsAffected =
          await DatabaseHelper.instance.updateRemarks(updatedRemarks);
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
    }
  }

  Future<void> _markAsRead() async {
    Map<String, dynamic> updatedRemarks = {
      DatabaseHelper.columnTaskId: widget.taskId,
      DatabaseHelper.columnRemarksStat:"read",
    };
    int rowsAffected =
    await DatabaseHelper.instance.updateRemarks(updatedRemarks);
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
  }
}
