class Obat {
  String nama;
  String deskripsi;
  String gambarUrl;
  int harga;

  Obat({
    required this.nama,
    required this.deskripsi,
    required this.gambarUrl,
    required this.harga,
  });

  factory Obat.fromMap(Map<String, dynamic> data) {
    return Obat(
      nama: data['nama'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      gambarUrl: data['gambarUrl'] ?? '',
      harga: data['harga'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'gambarUrl': gambarUrl,
      'harga': harga,
    };
  }
}
