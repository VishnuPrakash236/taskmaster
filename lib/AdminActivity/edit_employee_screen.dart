import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import '../DatabaseHelper/database_helper.dart';


class EditEmployeeScreen extends StatefulWidget {
  final Map<String, dynamic> employee;

  EditEmployeeScreen({required this.employee});

  @override
  _EditEmployeeScreenState createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _roleController;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  Map<String, dynamic>? pathfromdb;
  String path = 'null';
  File? p;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee['name']);
    _emailController = TextEditingController(text: widget.employee['email']);
    _passwordController =
        TextEditingController(text: widget.employee['password']);
    _roleController = TextEditingController(text: widget.employee['role']);
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    // Uint8List? image = await dbHelper.getUserProfile(widget.employee['email']);
    pathfromdb = await dbHelper.getUserProfilePath(widget.employee['email']);

    print(pathfromdb?['imgPath']);
    // print(p);

    setState(() {
      selectedImage = File(pathfromdb?['imgPath']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Employee'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Stack(
                  children: [
                    selectedImage != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: FileImage(selectedImage!),
                          )
                        : CircleAvatar(
                            radius: 64,
                            backgroundImage:
                                AssetImage('assets/bgimages/bg1.jpeg'),
                          ),
                    Positioned(
                      child: IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: () {
                          print("Pick image button pressed");
                          _pickImageFromGallery();
                        },
                      ),
                      bottom: -10,
                      left: 80,
                    )
                  ],
                ),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _roleController,
                decoration: InputDecoration(
                  labelText: 'Role',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => _updateEmployee(context),
                child: Text('Update Employee'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateEmployee(BuildContext context) async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String role = _roleController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || role.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please fill in all fields!',
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    if (path == null) {
      path = 'null';
    }
    Map<String, dynamic> updatedEmployee = {
      '_id': widget.employee['_id'],
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'imgPath': path
    };

    DatabaseHelper dbHelper = DatabaseHelper.instance;
    int rowsAffected = await dbHelper.updateUser(updatedEmployee);

    //on success db update

    if (rowsAffected > 0) {
      if (path != pathfromdb!['imgPath']) {
        // print('path from db:${pathfromdb!['imgPath']}');
        // _deleteSelectedImage();
      }

      Fluttertoast.showToast(
        msg: 'Employee updated successfully!',
        toastLength: Toast.LENGTH_SHORT,
      );
      Navigator.pop(
          context); // Return to previous screen after updating employee
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to update employee. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final DateTime now = DateTime.now();
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        final String formatted = formatter.format(now);
        print(formatted);
        Directory directory = await getApplicationDocumentsDirectory();
        path = '${directory.path}/${formatted}${_nameController.text}.jpg';
        File imageFile = File(pickedImage.path);
        File newImage = await imageFile.copy(path);
        // print('newImage: $newImage');
        setState(() {
          selectedImage = newImage;
        });

        print("Image saved at: ${newImage.path}");
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Image picker error: $e");
    }
  }

  Future<void> _deleteSelectedImage() async {
    if (selectedImage != null) {
      try {
        await pathfromdb!['imgPath']!.delete();
        Fluttertoast.showToast(
          msg: 'Image deleted successfully!',
          toastLength: Toast.LENGTH_SHORT,
        );
      } catch (e) {
        print("Error deleting image: $e");
        Fluttertoast.showToast(
          msg: 'Failed to delete image. Please try again.',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }
}
