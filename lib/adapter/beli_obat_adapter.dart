import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/obat.dart';

class BeliObatAdapter {
  final List<Obat> obatList;
  final Function(Obat) onItemClick;
  String searchText;

  BeliObatAdapter({
    required this.obatList,
    required this.onItemClick,
    this.searchText = '',
  });

  void setSearchText(String text) {
    searchText = text;
  }

  Widget buildItem(BuildContext context, int index) {
    Obat obat = obatList[index];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: obat.gambarUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        title: Text(obat.nama),
        subtitle: Text("Rp. ${obat.harga}"),
        onTap: () => onItemClick(obat),
      ),
    );
  }
}
