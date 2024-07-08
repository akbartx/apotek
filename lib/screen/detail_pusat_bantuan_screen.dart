import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPusatBantuanScreen extends StatefulWidget {
  @override
  _DetailPusatBantuanScreenState createState() => _DetailPusatBantuanScreenState();
}

class _DetailPusatBantuanScreenState extends State<DetailPusatBantuanScreen> {
  late SharedPreferences sharedPreferences;

  final List<String> doctorContacts = [
    "Dr.Bedah Umum RS.Kasih Ibu: https://doctor.kih.co.id/schedule/DOK2018100003",
    "Dr. Anak RS.Kasih Ibu: https://doctor.kih.co.id/schedule/DOK2017070077",
    "Dr. Bedah Tulang RS.Kasih Ibu: https://doctor.kih.co.id/schedule/DOK2017060032",
    "Dr. Bedah Kulit & Kelamin RS.Kasih Ibu: https://doctor.kih.co.id/schedule/DOK2018110003",
    "Dr. Mata RS.Kasih Ibu: https://doctor.kih.co.id/schedule/DOK2023100003",
  ];

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    bool isLoggedIn = sharedPreferences.getBool('isLoggedIn') ?? false;
    if (!isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  void openWebsite(String contact) async {
    final Uri url = Uri.parse(contact.split(': ')[1]);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka situs web')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pusat Bantuan'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: doctorContacts.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(doctorContacts[index].split(': ')[0]),
              onTap: () => openWebsite(doctorContacts[index]),
            ),
          );
        },
      ),
    );
  }
}
