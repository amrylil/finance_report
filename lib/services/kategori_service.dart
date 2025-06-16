import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; // Pastikan path ini benar
import '../models/kategori.dart'; // Pastikan path ini benar

class KategoriService {
  // GET: Mengambil semua kategori
  Future<List<Kategori>> fetchKategori(String token) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/kategori'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((item) => Kategori.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }

  // POST: Membuat kategori baru
  Future<Kategori> createKategori({
    required String token,
    required String nama,
    required String tipe,
  }) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/kategori'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({'nama': nama, 'tipe': tipe}),
    );

    if (response.statusCode == 201) {
      return Kategori.fromJson(json.decode(response.body)['data']);
    } else {
      final errorBody = json.decode(response.body);
      // Menangkap pesan error validasi dari API jika ada
      throw Exception(errorBody['message'] ?? 'Gagal membuat kategori baru.');
    }
  }

  // PUT: Memperbarui kategori
  Future<Kategori> updateKategori({
    required String token,
    required String id,
    String? nama, // Dibuat opsional
    String? tipe, // Dibuat opsional
  }) async {
    // Membuat map hanya dengan field yang tidak null untuk dikirim
    final Map<String, String> body = {};
    if (nama != null) body['nama'] = nama;
    if (tipe != null) body['tipe'] = tipe;

    final response = await http.put(
      Uri.parse('$BASE_URL/kategori/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Kategori.fromJson(json.decode(response.body)['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Gagal memperbarui kategori.');
    }
  }

  // DELETE: Menghapus kategori
  Future<void> deleteKategori(String token, String id) async {
    final response = await http.delete(
      Uri.parse('$BASE_URL/kategori/$id'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    // Status 200 atau 204 (No Content) dianggap berhasil
    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Gagal menghapus kategori.');
    }
  }
}
