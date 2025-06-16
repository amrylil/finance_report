import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; // Pastikan path ini benar
import '../models/transaksi.dart'; // Pastikan path ini benar

class TransaksiService {
  // GET: Mengambil semua transaksi
  Future<List<Transaksi>> fetchTransaksi(String token) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/transaksi'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((item) => Transaksi.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat transaksi');
    }
  }

  // POST: Membuat transaksi baru
  Future<Transaksi> createTransaksi({
    required String token,
    required String deskripsi,
    required double jumlah,
    required String tipe,
    required DateTime tanggal,
    required String idKategori,
    required String idDompet,
  }) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/transaksi'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'deskripsi': deskripsi,
        'jumlah': jumlah.toString(),
        'tipe': tipe,
        'tanggal': tanggal.toIso8601String().split('T').first, // Format Y-m-d
        'id_kategori': idKategori,
        'id_dompet': idDompet,
      }),
    );

    if (response.statusCode == 201) {
      return Transaksi.fromJson(json.decode(response.body)['data']);
    } else {
      // Menangkap pesan error validasi dari API jika ada
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Gagal membuat transaksi baru.');
    }
  }

  // PUT: Memperbarui transaksi
  Future<Transaksi> updateTransaksi({
    required String token,
    required String id,
    String? deskripsi,
    double? jumlah,
    String? tipe,
    DateTime? tanggal,
    String? idKategori,
    String? idDompet,
  }) async {
    // Membuat map hanya dengan field yang tidak null
    final Map<String, String> body = {};
    if (deskripsi != null) body['deskripsi'] = deskripsi;
    if (jumlah != null) body['jumlah'] = jumlah.toString();
    if (tipe != null) body['tipe'] = tipe;
    if (tanggal != null)
      body['tanggal'] = tanggal.toIso8601String().split('T').first;
    if (idKategori != null) body['id_kategori'] = idKategori;
    if (idDompet != null) body['id_dompet'] = idDompet;

    final response = await http.put(
      Uri.parse('$BASE_URL/transaksi/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Transaksi.fromJson(json.decode(response.body)['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Gagal memperbarui transaksi.');
    }
  }

  // DELETE: Menghapus transaksi
  Future<void> deleteTransaksi(String token, String id) async {
    final response = await http.delete(
      Uri.parse('$BASE_URL/transaksi/$id'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    // Status 200 atau 204 (No Content) dianggap berhasil
    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Gagal menghapus transaksi.');
    }
  }
}
