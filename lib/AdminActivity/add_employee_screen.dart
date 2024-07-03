import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../DatabaseHelper/database_helper.dart';



class AddEmployeeScreen extends StatefulWidget {
  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _roleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  String path = 'null';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Employee'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
                onPressed: () => _addEmployee(context),
                child: Text('Add Employee'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addEmployee(BuildContext context) async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String role = _roleController.text.trim();

    if (path == null) {
      path = 'null';
    }
    Map<String, dynamic> newEmployee = {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'imgPath':path,
    };

    DatabaseHelper dbHelper = DatabaseHelper.instance;
    int id = await dbHelper.insertUser(newEmployee);

    if (id != 0) {
      Fluttertoast.showToast(
        msg: 'Employee added successfully!',
        toastLength: Toast.LENGTH_SHORT,
      );
      Navigator.pop(context); // Return to previous screen after adding employee
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to add employee. Please try again.',
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
}
