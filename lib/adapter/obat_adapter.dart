import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/obat.dart';

class ObatAdapter extends StatelessWidget {
  final List<Obat> obatList;
  final Function(Obat) onItemClick;

  ObatAdapter({
    required this.obatList,
    required this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: obatList.length,
      itemBuilder: (context, index) {
        return ObatCard(
          obat: obatList[index],
          onItemClick: onItemClick,
        );
      },
    );
  }
}

class ObatCard extends StatelessWidget {
  final Obat obat;
  final Function(Obat) onItemClick;

  ObatCard({
    required this.obat,
    required this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => onItemClick(obat),
        leading: CachedNetworkImage(
          imageUrl: obat.gambarUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        title: Text(obat.nama),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(obat.deskripsi),
            Text("Rp. ${obat.harga}"),
          ],
        ),
      ),
    );
  }
}
