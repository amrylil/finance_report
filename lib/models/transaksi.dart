import './kategori.dart';
import './dompet.dart';

class Transaksi {
  final String id;
  final String deskripsi;
  final double jumlah;
  final String tipe;
  final DateTime tanggal;
  final Kategori kategori;
  final Dompet dompet;

  Transaksi({
    required this.id,
    required this.deskripsi,
    required this.jumlah,
    required this.tipe,
    required this.tanggal,
    required this.kategori,
    required this.dompet,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      deskripsi: json['deskripsi'],
      jumlah: double.parse(json['jumlah'].toString()),
      tipe: json['tipe'],
      tanggal: DateTime.parse(json['tanggal']),
      kategori: Kategori.fromJson(json['kategori']),
      dompet: Dompet.fromJson(json['dompet']),
    );
  }
}
