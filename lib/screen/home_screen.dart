import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_beli_obat_screen.dart';
import 'detail_consultasi_screen.dart';
import 'detail_info_obat_screen.dart';
import 'detail_pusat_bantuan_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SharedPreferences sharedPreferences;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Apoteku',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              Text(
                'Being Good Being Healthy',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.blue[900],
                ),
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/images/logo.jpg',
                height: 160,
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: <Widget>[
                    _buildCard(
                      title: 'Konsultasi Ahli',
                      image: 'assets/images/konsul.jpg',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => DetailKonsultasiScreen()),
                        );
                      },
                    ),
                    _buildCard(
                      title: 'Beli Obat',
                      image: 'assets/images/obat.jpg',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => DetailBeliObatScreen()),
                        );
                      },
                    ),
                    _buildCard(
                      title: 'Informasi Obat',
                      image: 'assets/images/info.jpg',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => DetailInfoObatScreen()),
                        );
                      },
                    ),
                    _buildCard(
                      title: 'Pusat Bantuan',
                      image: 'assets/images/bantuan.jpg',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => DetailPusatBantuanScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required String image, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 10),
            Image.asset(
              image,
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
