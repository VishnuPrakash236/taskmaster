import 'package:flutter/material.dart';

import '../DatabaseHelper/database_helper.dart';

class Remarks extends StatefulWidget {
  final int taskId;
  final String taskName;

  const Remarks({super.key, required this.taskId, required this.taskName});

  @override
  State<Remarks> createState() => _RemarksState();
}

class _RemarksState extends State<Remarks> {
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
    _subjectController=TextEditingController();
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
      _subjectController=TextEditingController(text: task['remarks_subject'].toString());
    });

    print("1" + ExistingRemarks);
  }

  @override
  void dispose() {
    _remarksController.removeListener(_updateMaxLines);
    _remarksController.dispose();
    super.dispose();
  }

  void _updateMaxLines() {
    final int lineCount = '\n'.allMatches(_remarksController.text).length + 1;
    setState(() {
      _maxLines = lineCount;
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    print("2" + ExistingRemarks);
    return Scaffold(
      appBar: AppBar(
        title: Text('Remarks for ${widget.taskName}'),
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
                        _remarksController.text="";
                      },
                      child: Text('Clear'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: ElevatedButton(
                      onPressed: () {},
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
        DatabaseHelper.columnRemarksSubject:_subjectController.text,
        DatabaseHelper.columnRemarksStat:"not_opened",
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
}
