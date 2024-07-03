import 'package:flutter/material.dart';

class ExpandableTextField extends StatefulWidget {
  final String remarksText;

  const ExpandableTextField({super.key , required this.remarksText});

  @override
  _ExpandableTextFieldState createState() => _ExpandableTextFieldState();
}

class _ExpandableTextFieldState extends State<ExpandableTextField> {
  late  TextEditingController _remarksController;
  int _maxLines = 1;

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController(text: widget.remarksText);
    _remarksController.addListener(_updateMaxLines);

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

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}


