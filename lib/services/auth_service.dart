import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 201) {
      // Simpan token jika registrasi berhasil
      await _saveToken(responseData['access_token']);
      return responseData;
    } else {
      // Lempar error beserta pesan dari API
      throw Exception(responseData['message'] ?? 'Gagal melakukan registrasi.');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      // Simpan token jika login berhasil
      await _saveToken(responseData['access_token']);
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Gagal melakukan login.');
    }
  }

  Future<void> logout(String token) async {
    try {
      await http.post(
        Uri.parse('$BASE_URL/logout'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    } finally {
      // Apapun yang terjadi di server, hapus token di client
      await _clearToken();
    }
  }

  // Fungsi helper untuk menyimpan token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Fungsi helper untuk menghapus token
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Fungsi untuk mendapatkan token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
