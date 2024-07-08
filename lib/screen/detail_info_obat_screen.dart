import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../model/obat.dart';
import '../adapter/obat_adapter.dart';

class DetailInfoObatScreen extends StatefulWidget {
  @override
  _DetailInfoObatScreenState createState() => _DetailInfoObatScreenState();
}

class _DetailInfoObatScreenState extends State<DetailInfoObatScreen> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('obat');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info Obat'),
      ),
      body: StreamBuilder(
        stream: databaseReference.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final List<Obat> obatList = [];
            final data = snapshot.data!.snapshot.value;
            if (data is Map) {
              Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
              map.forEach((key, value) {
                Obat obat = Obat.fromMap(Map<String, dynamic>.from(value));
                obatList.add(obat);
              });
            } else if (data is List) {
              List<dynamic> list = List<dynamic>.from(data as List);
              list.forEach((value) {
                if (value != null) {
                  Obat obat = Obat.fromMap(Map<String, dynamic>.from(value));
                  obatList.add(obat);
                }
              });
            }
            return ObatAdapter(
              obatList: obatList,
              onItemClick: (obat) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailInfoObatScreen(), // Ganti dengan layar detail obat jika ada
                    settings: RouteSettings(arguments: obat.nama),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
