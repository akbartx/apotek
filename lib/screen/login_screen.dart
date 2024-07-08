import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController loginUsernameController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    bool isLoggedIn = sharedPreferences.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      startDashboardActivity();
    }
  }

  void startDashboardActivity() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  void checkUser() async {
    String userUsername = loginUsernameController.text.trim();
    String userPassword = loginPasswordController.text.trim();

    DatabaseReference reference = FirebaseDatabase.instance.reference().child('users');
    Query checkUserDatabase = reference.orderByChild('username').equalTo(userUsername);

    try {
      DatabaseEvent event = await checkUserDatabase.once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> userSnapshot = snapshot.value as Map<dynamic, dynamic>;
        userSnapshot.forEach((key, value) {
          String passwordFromDB = value['password'];
          if (passwordFromDB == userPassword) {
            sharedPreferences.setBool('isLoggedIn', true);
            sharedPreferences.setString('username', userUsername);
            startDashboardActivity();
          } else {
            showError('Invalid Password');
          }
        });
      } else {
        showError('Invalid Username');
      }
    } catch (error) {
      showError('Database Error');
    }
  }

  void showError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 20,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 36,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: loginUsernameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: loginPasswordController,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (validateFields()) {
                          checkUser();
                        } else {
                          showError('Please fill your data first!');
                        }
                      },
                      child: Text('Login', style: TextStyle(fontSize: 18)),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => RegisterScreen()),
                        );
                      },
                      child: Text('Don\'t have an account? Register Now'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool validateFields() {
    return loginUsernameController.text.isNotEmpty && loginPasswordController.text.isNotEmpty;
  }
}
