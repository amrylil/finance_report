import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/dompet.dart';

class DompetService {
  Future<List<Dompet>> fetchDompet(String token) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/dompet'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((item) => Dompet.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat dompet');
    }
  }

  // CREATE DOMPET
  Future<Dompet> createDompet(
    String token,
    String nama,
    double saldoAwal,
  ) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/dompet'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({'nama': nama, 'saldo_awal': saldoAwal.toString()}),
    );
    if (response.statusCode == 201) {
      return Dompet.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Gagal membuat dompet baru.');
    }
  }

  // UPDATE DOMPET
  Future<Dompet> updateDompet(
    String token,
    String id,
    String nama,
    double saldoAwal,
  ) async {
    final response = await http.put(
      Uri.parse('$BASE_URL/dompet/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({'nama': nama, 'saldo_awal': saldoAwal.toString()}),
    );
    if (response.statusCode == 200) {
      return Dompet.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Gagal mengupdate dompet.');
    }
  }

  // DELETE DOMPET
  Future<bool> deleteDompet(String token, String id) async {
    final response = await http.delete(
      Uri.parse('$BASE_URL/dompet/$id'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Gagal menghapus dompet.');
    }
  }
}
