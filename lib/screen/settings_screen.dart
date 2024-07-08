import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../model/user.dart';
import 'login_screen.dart';

class SettingScreen extends StatefulWidget {
  final String username;

  SettingScreen({required this.username});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late SharedPreferences sharedPreferences;
  final TextEditingController usernameController = TextEditingController();
  final DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('users');
  final Reference storageReference = FirebaseStorage.instance.ref().child('profile_images');
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    DataSnapshot dataSnapshot = await databaseReference.child(widget.username).get();
    if (dataSnapshot.value != null) {
      User user = User.fromData(dataSnapshot.value as Map<String, dynamic>);
      setState(() {
        usernameController.text = user.username;
        if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
          // Assuming you load the image using a file path, if it's a URL adjust accordingly
          // _image = File(user.photoUrl);
        }
      });
    }
  }

  Future<void> _openFilePicker() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveUserData() async {
    final newUsername = usernameController.text.trim();
    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Username tidak boleh kosong')));
      return;
    }
    String? photoUrl;
    if (_image != null) {
      final uploadTask = storageReference.child('$newUsername.jpg').putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() {});
      photoUrl = await snapshot.ref.getDownloadURL();
    }
    await updateUserInDatabase(newUsername, photoUrl);
  }

  Future<void> updateUserInDatabase(String newUsername, String? photoUrl) async {
    DatabaseReference userReference = databaseReference.child(widget.username);
    DataSnapshot dataSnapshot = await userReference.get();
    if (dataSnapshot.value != null) {
      User user = User.fromData(dataSnapshot.value as Map<String, dynamic>);
      String oldUsername = user.username;
      User updatedUser = User(
        username: newUsername,
        email: user.email,
        password: user.password,
        confirmPassword: user.confirmPassword,
        photoUrl: photoUrl ?? user.photoUrl,
      );
      await databaseReference.child(oldUsername).remove();
      await databaseReference.child(newUsername).set(updatedUser.toJson());

      sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.remove('isLoggedIn');
      sharedPreferences.remove('username');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: _image != null ? FileImage(_image!) : AssetImage('assets/images/image_profile.png') as ImageProvider,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _openFilePicker,
              child: Text('Pilih Foto'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveUserData,
              child: Text('Simpan'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
