import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../adapter/beli_obat_adapter.dart';
import '../model/obat.dart';
import 'midtrans_payment_screen.dart';

class DetailBeliObatScreen extends StatefulWidget {
  @override
  _DetailBeliObatScreenState createState() => _DetailBeliObatScreenState();
}

class _DetailBeliObatScreenState extends State<DetailBeliObatScreen> {
  final List<Obat> obatList = [];
  final List<Obat> filteredList = [];
  late BeliObatAdapter obatAdapter;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    obatAdapter = BeliObatAdapter(
      obatList: filteredList,
      onItemClick: (obat) => startMidtransPayment(obat),
    );
    fetchDataFromFirebase();
  }

  void startMidtransPayment(Obat obat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MidtransPaymentScreen(obat: obat),
      ),
    );
  }

  void fetchDataFromFirebase() {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('obat');
    databaseReference.onValue.listen((event) {
      setState(() {
        obatList.clear();
        if (event.snapshot.value != null) {
          final data = event.snapshot.value;
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
        }
        filteredList.clear();
        filteredList.addAll(obatList);
        filter(searchController.text); // Apply filter if there is any text
      });
    }, onError: (error) {
      // Handle possible errors
      print('Error: $error');
    });
  }

  void filter(String text) {
    setState(() {
      filteredList.clear();
      for (Obat item in obatList) {
        if (item.nama.toLowerCase().contains(text.toLowerCase())) {
          filteredList.add(item);
        }
      }
      obatAdapter.setSearchText(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beli Obat'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari obat',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (text) => filter(text),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return obatAdapter.buildItem(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
