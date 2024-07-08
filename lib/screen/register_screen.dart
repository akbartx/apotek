import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'login_screen.dart';
import '../model/user.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController registerUsernameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();
  final TextEditingController registerConfirmPasswordController = TextEditingController();

  final DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users');
  final Reference storageReference = FirebaseStorage.instance.ref().child('profile_images');

  File? _image;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void _registerUser() async {
    String username = registerUsernameController.text.trim();
    String email = registerEmailController.text.trim();
    String password = registerPasswordController.text.trim();
    String confirmPassword = registerConfirmPasswordController.text.trim();

    if (!_validateFields()) {
      _showToast('Please fill your data first!');
      return;
    }

    if (_image != null) {
      await _uploadPhotoAndSaveUser(username, email, password, confirmPassword);
    } else {
      _saveUserToDatabase(username, email, password, confirmPassword, null);
    }
  }

  bool _validateFields() {
    return _validateUsername() &&
        _validateEmail() &&
        _validatePassword() &&
        _validateConfirmPassword();
  }

  bool _validateUsername() {
    String val = registerUsernameController.text.trim();
    if (val.isEmpty) {
      _showToast('Username not filled yet');
      return false;
    }
    return true;
  }

  bool _validateEmail() {
    String val = registerEmailController.text.trim();
    if (val.isEmpty) {
      _showToast('Email not filled yet');
      return false;
    }
    return true;
  }

  bool _validatePassword() {
    String val = registerPasswordController.text.trim();
    if (val.isEmpty) {
      _showToast('Password not filled yet');
      return false;
    }
    return true;
  }

  bool _validateConfirmPassword() {
    String val = registerConfirmPasswordController.text.trim();
    if (val.isEmpty) {
      _showToast('Confirm Password not filled yet');
      return false;
    }
    return true;
  }

  Future<void> _uploadPhotoAndSaveUser(String username, String email, String password, String confirmPassword) async {
    try {
      TaskSnapshot taskSnapshot = await storageReference.child('$username.jpg').putFile(_image!);
      String photoUrl = await taskSnapshot.ref.getDownloadURL();
      _saveUserToDatabase(username, email, password, confirmPassword, photoUrl);
    } catch (e) {
      _showToast('Photo upload failed: $e');
    }
  }

  void _saveUserToDatabase(String username, String email, String password, String confirmPassword, String? photoUrl) {
    if (username.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      User user = User(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        photoUrl: photoUrl ?? '',
      );

      databaseReference.child(username).set(user.toJson()).then((_) {
        _showToast('Registration process success!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }).catchError((error) {
        _showToast('Failed to register: $error');
      });
    } else {
      _showToast('All fields are required!');
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                      'Register',
                      style: TextStyle(
                        fontSize: 36,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null ? FileImage(_image!) : AssetImage('assets/images/image_profile.png') as ImageProvider,
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: _pickImage,
                      child: Text('Pilih Gambar'),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: registerUsernameController,
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
                      controller: registerEmailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: registerPasswordController,
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
                    TextField(
                      controller: registerConfirmPasswordController,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _registerUser,
                      child: Text('Register', style: TextStyle(fontSize: 18)),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text('Already have an account? Login'),
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
}
