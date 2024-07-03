import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AdminActivity/admin_dash.dart';
import 'DatabaseHelper/database_helper.dart';
import 'EmpActivity/emp_dashboard.dart';
import 'utils/text_utils.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isAdmin = false;
  bool _saveCredentials = false; // Added boolean for saving credentials
  late String imagename = 'bg2.jpeg';

  @override
  void initState() {
    super.initState();
    _getSavedCredentials(); // Load saved credentials on initialization
    getDBVersion();
  }

  void getDBVersion() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;

    int version = await dbHelper.getDatabaseVersion();
    print('Database version: $version');
  }

  void _getSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _saveCredentials = prefs.getBool('saveCredentials') ?? false;
      if (_saveCredentials) {
        _emailController.text = prefs.getString('savedEmail') ?? '';
        _passwordController.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  void _saveCredentialsToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('saveCredentials', _saveCredentials);
    if (_saveCredentials) {
      await prefs.setString('savedEmail', _emailController.text.trim());
      await prefs.setString('savedPassword', _passwordController.text.trim());
    } else {
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bgimages/$imagename'),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          height: 400,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Center(
                          child: TextUtil(
                        text: "Login",
                        weight: true,
                        size: 30,
                      )),
                      const Spacer(),
                      TextUtil(
                        text: "Email",
                      ),
                      Container(
                        height: 35,
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.white))),
                        child: TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            suffixIcon: Icon(
                              Icons.mail,
                              color: Colors.white,
                            ),
                            fillColor: Colors.white,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextUtil(
                        text: "Password",
                      ),
                      Container(
                        height: 35,
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.white))),
                        child: TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            suffixIcon: Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            fillColor: Colors.white,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              checkColor: Colors.green,
                              tileColor: Colors.white,
                              activeColor: Colors.white,
                              side: BorderSide(color: Colors.white),
                              title: TextUtil(text: 'Admin Login'),
                              value: _isAdmin,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (_isAdmin) {
                                    imagename = 'bg2.jpeg';
                                  } else {
                                    imagename = 'bg3.jpeg';
                                  }
                                  _isAdmin = value ?? false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              checkColor: Colors.green,
                              tileColor: Colors.white,
                              activeColor: Colors.white,
                              side: BorderSide(color: Colors.white),
                              title: TextUtil(text: 'Remember Me'),
                              value: _saveCredentials,
                              onChanged: (bool? value) {
                                setState(() {
                                  _saveCredentials = value ?? false;
                                  _saveCredentialsToPrefs(); // Save state to SharedPreferences
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Spacer(),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _login(context),
                          child: TextUtil(
                            text: 'Login',
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Spacer(),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    String email = _emailController.text.trim();
    print(_emailController.text);
    print(_passwordController.text);

    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Email and password are required!',
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    DatabaseHelper dbHelper = DatabaseHelper.instance;
    Map<String, dynamic>? user = await dbHelper.queryUser(email);

    if (user != null) {
      if (user['password'] == password) {
        // Successful login
        if (_isAdmin && user['role'] != 'admin') {
          Fluttertoast.showToast(
            msg: 'This account is not an admin account!',
            toastLength: Toast.LENGTH_SHORT,
          );
        } else if (_isAdmin) {
          // Navigate to admin dashboard
          Navigator.pushReplacement(
            context,
            // MaterialPageRoute(builder: (context) => AdminDashboard()),
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        } else {
          // Navigate to employee dashboard
          Navigator.pushReplacement(
            context,
            // MaterialPageRoute(
            // builder: (context) => EmployeeDashboard(employeeName: user['name']),
            MaterialPageRoute(
                builder: (context) =>
                    EmployeeDashboard(employeeName: user['name'])),
            // ),
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Incorrect password!',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'User not found!',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}
