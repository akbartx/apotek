import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/obat.dart';
import 'webview_screen.dart';

class MidtransPaymentScreen extends StatefulWidget {
  final Obat obat;

  MidtransPaymentScreen({required this.obat});

  @override
  _MidtransPaymentScreenState createState() => _MidtransPaymentScreenState();
}

class _MidtransPaymentScreenState extends State<MidtransPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bayar sekarang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.obat.nama,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Rp. ${widget.obat.harga}",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                proceedToPayment();
              },
              child: Text('Bayar Sekarang'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void proceedToPayment() async {
    Fluttertoast.showToast(
      msg: "Proses pembayaran...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    final String serverUrl = 'https://app.indit.online/midtrans.php/';

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "transaction_details": {
            "order_id": "order-${DateTime.now().millisecondsSinceEpoch}",
            "gross_amount": widget.obat.harga,
          },
          "item_details": [
            {
              "id": widget.obat.nama,
              "price": widget.obat.harga,
              "quantity": 1,
              "name": widget.obat.nama,
            },
          ],
          "customer_details": {
            "first_name": "FirstName",
            "last_name": "LastName",
            "email": "customer@example.com",
            "phone": "08123456789",
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var result = jsonDecode(response.body);
        var redirectUrl = result['redirect_url'];
        print('Redirect URL: $redirectUrl');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(url: redirectUrl),
          ),
        );
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        Fluttertoast.showToast(
          msg: "Pembayaran gagal. Status: ${response.statusCode}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(
        msg: "Pembayaran gagal. Error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
