// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:use_case4/EmpActivity/emp_dashboard.dart';
// import 'package:use_case4/AdminActivity/admin_dash.dart';
//
// import 'DatabaseHelper/database_helper.dart';
//
// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//   bool _isAdmin = false;
//   bool _saveCredentials = false; // Added boolean for saving credentials
//
//   @override
//   void initState() {
//     super.initState();
//     _getSavedCredentials(); // Load saved credentials on initialization
//     getDBVersion();
//   }
//
//   void getDBVersion() async {
//     DatabaseHelper dbHelper = DatabaseHelper.instance;
//
//     int version = await dbHelper.getDatabaseVersion();
//     print('Database version: $version');
//   }
//
//   void _getSavedCredentials() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _saveCredentials = prefs.getBool('saveCredentials') ?? false;
//       if (_saveCredentials) {
//         _emailController.text = prefs.getString('savedEmail') ?? '';
//         _passwordController.text = prefs.getString('savedPassword') ?? '';
//       }
//     });
//   }
//
//   void _saveCredentialsToPrefs() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('saveCredentials', _saveCredentials);
//     if (_saveCredentials) {
//       await prefs.setString('savedEmail', _emailController.text.trim());
//       await prefs.setString('savedPassword', _passwordController.text.trim());
//     } else {
//       await prefs.remove('savedEmail');
//       await prefs.remove('savedPassword');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login'),
//       ),
//       body: Container(
//         height: double.infinity,
//         width: double.infinity,
//         decoration: BoxDecoration(
//             image: DecorationImage(
//                 image: AssetImage('assets/bg2.jpeg'), fit: BoxFit.fill)),
//         child: Container(
//           height: double.infinity,
//           width: double.infinity,
//           margin: const EdgeInsets.symmetric(horizontal: 30),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.white),
//             borderRadius: BorderRadius.circular(15),
//             color: Colors.black.withOpacity(0.1),
//           ),
//
//           child: Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//
//               children: <Widget>[
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                   ),
//                 ),
//                 SizedBox(height: 20.0),
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoaration: InputDecoration(
//                     labelText: 'Password',
//                   ),
//                 ),
//                 SizedBox(height: 20.0),
//                 CheckboxListTile(
//                   title: Text('Admin Login'),
//                   value: _isAdmin,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       _isAdmin = value ?? false;
//                     });
//                   },
//                 ),
//                 CheckboxListTile(
//                   title: Text('Save credentials'),
//                   value: _saveCredentials,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       _saveCredentials = value ?? false;
//                       _saveCredentialsToPrefs(); // Save state to SharedPreferences
//                     });
//                   },
//                 ),
//                 SizedBox(height: 20.0),
//                 ElevatedButton(
//                   onPressed: () => _login(context),
//                   child: Text('Login'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _login(BuildContext context) async {
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();
//
//     if (email.isEmpty || password.isEmpty) {
//       Fluttertoast.showToast(
//         msg: 'Email and password are required!',
//         toastLength: Toast.LENGTH_SHORT,
//       );
//       return;
//     }
//
//     DatabaseHelper dbHelper = DatabaseHelper.instance;
//     Map<String, dynamic>? user = await dbHelper.queryUser(email);
//
//     if (user != null) {
//       if (user['password'] == password) {
//         // Successful login
//         if (_isAdmin && user['role'] != 'admin') {
//           Fluttertoast.showToast(
//             msg: 'This account is not an admin account!',
//             toastLength: Toast.LENGTH_SHORT,
//           );
//         } else if (_isAdmin) {
//           // Navigate to admin dashboard
//           Navigator.pushReplacement(
//             context,
//             // MaterialPageRoute(builder: (context) => AdminDashboard()),
//             MaterialPageRoute(builder: (context) => AdminDashboard()),
//           );
//         } else {
//           // Navigate to employee dashboard
//           Navigator.pushReplacement(
//             context,
//             // MaterialPageRoute(
//             // builder: (context) => EmployeeDashboard(employeeName: user['name']),
//             MaterialPageRoute(
//                 builder: (context) =>
//                     EmployeeDashboard(employeeName: user['name'])),
//             // ),
//           );
//         }
//       } else {
//         Fluttertoast.showToast(
//           msg: 'Incorrect password!',
//           toastLength: Toast.LENGTH_SHORT,
//         );
//       }
//     } else {
//       Fluttertoast.showToast(
//         msg: 'User not found!',
//         toastLength: Toast.LENGTH_SHORT,
//       );
//     }
//   }
// }
